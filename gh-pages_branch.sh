
if [[ -z $(git ls-remote --heads origin gh-pages) ]]; then
   echo "Creating gh-pages branch"
   git config --global user.email ${{ steps.committer.outputs.email }}
   git config --global user.name ${{ steps.committer.outputs.name }}
   git checkout --orphan gh-pages
   git reset --hard
   git commit --allow-empty -m "First commit to create gh-pages branch"
   git push origin gh-pages
   git checkout main
   echo "Created gh-pages branch"
else
   echo "Branch gh-pages already exists"
fi

