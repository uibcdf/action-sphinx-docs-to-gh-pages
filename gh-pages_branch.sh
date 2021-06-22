echo "::group::Checking if gh-pages branch exists"

if [[ -z $(git ls-remote --heads origin gh-pages) ]]; then
   echo "Creating gh-pages branch"
   git checkout --orphan gh-pages
   git reset --hard
   git commit --allow-empty -m "First commit to create gh-pages branch"
   git push origin gh-pages
   git checkout main
   echo "Created gh-pages branch"
else
   echo "Branch gh-pages already exists"
fi

echo "::endgroup::"

