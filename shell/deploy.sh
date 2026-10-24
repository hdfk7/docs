#!/usr/bin/env bash
# 可独立执行：bash deploy.sh，缓存保留在执行时的当前目录下。
set -Eeuo pipefail

repo_url='https://gitee.com/hdfk7/docs.git'
repo_branch='master'
deploy_dir='/usr/share/nginx/default'
work_dir="$(pwd -P)/hdfk7-deploy"
repo_dir="$work_dir/repo"
payload_dir="$work_dir/payload"

trap 'printf "部署失败（第 %s 行），本地缓存目录已保留。\n" "$LINENO" >&2' ERR

for tool in git rsync find md5sum; do
    command -v "$tool" >/dev/null 2>&1 || { printf '缺少依赖：%s\n' "$tool" >&2; exit 1; }
done

# 清空部署目录前，确认目标路径准确且具有写入权限。
mkdir -p -- "$deploy_dir"
deploy_real="$(cd -- "$deploy_dir" && pwd -P)"
if [[ "$deploy_real" != '/usr/share/nginx/default' || -L "$deploy_dir" ]]; then
    printf '目标必须是真实的 /usr/share/nginx/default，拒绝清空其他路径。\n' >&2
    exit 1
fi
[[ -w "$deploy_real" && -x "$deploy_real" ]] || { printf '没有部署目录写入权限。\n' >&2; exit 1; }

# 缓存必须是当前目录内的真实目录，且不能位于将被清空的部署目录中。
if [[ -L "$work_dir" || -L "$repo_dir" || -L "$payload_dir" || "$work_dir" == "$deploy_real" || "$work_dir" == "$deploy_real/"* ]]; then
    printf '缓存目录路径不安全，停止部署。\n' >&2
    exit 1
fi
mkdir -p -- "$work_dir"
[[ "$(cd -- "$work_dir" && pwd -P)" == "$work_dir" ]] || { printf '缓存目录路径发生变化，停止部署。\n' >&2; exit 1; }

# 在缓存仓库内执行 Git 命令。
git_in_repo() (
    cd -- "$repo_dir" || exit 1
    git "$@"
)

if [[ -d "$repo_dir/.git" && ! -L "$repo_dir/.git" ]] && git_in_repo rev-parse --verify HEAD >/dev/null 2>&1; then
    printf '还原缓存仓库，删除所有新增文件和本地修改…\n'
    git_in_repo reset --hard HEAD
    git_in_repo clean -ffdx
    git_in_repo remote set-url origin "$repo_url"
else
    # 仅清理已确认位于专用缓存目录内的不完整仓库，然后重新拉取。
    if [[ -e "$repo_dir" ]]; then
        rm -rf -- "$repo_dir"
    fi
    printf '未找到有效的本地仓库，重新拉取 %s 分支…\n' "$repo_branch"
    git clone --depth 1 --branch "$repo_branch" -- "$repo_url" "$repo_dir"
fi

printf '同步 %s 分支最新代码…\n' "$repo_branch"
git_in_repo fetch --depth 1 origin "+refs/heads/$repo_branch:refs/remotes/origin/$repo_branch"
git_in_repo checkout -B "$repo_branch" "origin/$repo_branch"
git_in_repo reset --hard "origin/$repo_branch"
git_in_repo clean -ffdx
[[ -z "$(git_in_repo status --porcelain --untracked-files=all)" ]] || { printf '缓存仓库不干净，停止部署。\n' >&2; exit 1; }
[[ -f "$repo_dir/index.html" ]] || { printf '下载内容缺少 index.html，停止部署。\n' >&2; exit 1; }
revision="$(git_in_repo rev-parse --short HEAD)"

# 同步完整项目到待部署目录，并清除上次部署遗留的文件。
mkdir -p -- "$payload_dir"
rsync -rlt --delete --delete-excluded --chmod=D755,F644 \
    --exclude='.git' --exclude='.gitignore' \
    --exclude='.gitattributes' --exclude='.gitmodules' \
    -- "$repo_dir/" "$payload_dir/"

# 只修改待部署副本的资源版本号，保持缓存 Git 仓库干净。
asset_hash="$(cd -- "$repo_dir" && find app -type f \( -name '*.js' -o -name '*.css' \) -print \
    | LC_ALL=C sort | xargs cat | md5sum | cut -c1-8)"
[[ -n "$asset_hash" ]] || { printf '无法计算静态资源版本号，停止部署。\n' >&2; exit 1; }
for page in index.html 404.html; do
    [[ -f "$payload_dir/$page" ]] || continue
    sed -i -E "s#(/app/[^\"?]+\.(js|css))(\?[^\"]*)?#\1?v=${asset_hash}#g" "$payload_dir/$page"
done

# 同步目标内容前再次确认，防止部署过程中目标路径发生变化。
[[ ! -L "$deploy_dir" && "$(cd -- "$deploy_dir" && pwd -P)" == '/usr/share/nginx/default' ]] || { printf '目标路径发生变化，停止部署。\n' >&2; exit 1; }
# 镜像同步会删除目标多余文件，待部署副本必须完整，否则会误删线上内容。
[[ -f "$payload_dir/index.html" ]] || { printf '待部署目录缺少 index.html，停止部署。\n' >&2; exit 1; }
printf '镜像同步到 %s（增量传输，删除目标多余文件）…\n' "$deploy_real"
if ! rsync -rlt --delete --chmod=D755,F644 -- "$payload_dir/" "$deploy_real/"; then
    printf '同步 %s 失败，目标可能残留部分已删除或已更新的文件，确认原因后重跑本脚本即可。\n' "$deploy_real" >&2
    exit 1
fi

# 同步后核对文件数，确认目标与待部署副本一致。
payload_files="$(find "$payload_dir" -type f | wc -l | tr -d ' ')"
deploy_files="$(find "$deploy_real" -type f | wc -l | tr -d ' ')"
if [[ "$payload_files" -ne "$deploy_files" ]]; then
    printf '文件数不一致：待部署 %s 个，部署目录 %s 个，请检查后再上线。\n' "$payload_files" "$deploy_files" >&2
    exit 1
fi
printf '部署完成，版本：%s，共 %s 个文件。\n' "$revision" "$deploy_files"
printf '本地缓存已保留：%s。静态文件无需重载 Nginx。\n' "$work_dir"
