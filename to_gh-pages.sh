echo ::group::Push to gh-pages
git add .
git commit --allow-empty -m "From XXX"
git push origin gh-pages
echo ::endgroup::

