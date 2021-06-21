author_name="$(git show --format=%an -s)"
author_email="$(git show --format=%ae -s)"

echo "::set-output name=name::"$author_name""
echo "::set-output name=email::"$author_email""

echo ::group::Set commiter
echo "git config user.name $author_name"
git config user.name $author_name
echo "git config user.email $author_email"
git config user.email $author_email
echo ::endgroup::

