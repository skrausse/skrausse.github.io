---
layout: post
title:  "How to publish your jupyter notebooks on github pages"
date:   2024-08-05
---

# Create github pages

- Setup a repository that is named ```<your_github_username>.github.io``` and make it public
- In settings make it a github pages repo
- Initialize with some ```index.html``` file, that could look something like this:

```html
<!DOCTYPE html>
<html>
  <head>
      <title>Hello World</title>
  </head>

  <body>
      <h1>Hello World!</h1>
  </body>
</html>
```
- Voila, your website is up and running. But ugly as hell...

# Using jekyll for easy page creation
- Trying to setup your own webpage is tedious. You could learn html and CSS to beatify your webpage, but there really is no need for that
- Using a build-tool, such as jekyll (recommended for github pages)
- Installation process (for WSL)
- Quick walkthrough of the default jekyll page.


# Integrating jupyter notebooks
- Creating a jupyter notebook somewhere and convert it to markdown
- Move markdown file to ```_posts``` folder
- Prepend a front matter to the markdown file
- Move assets if needed to assets folder and change path in markdown notebook
- Voila, your notebook is now available as a webpage.

# Automating the deployment of Jupyter notebooks
- Here is a script to automate the previous process:

```shell
#!/bin/bash

# Check if the notebook name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <notebook-name>"
  exit 1
fi

NOTEBOOK=$1
BASENAME=$(basename "$NOTEBOOK" .ipynb)
DATE=$(echo "$BASENAME" | cut -d'-' -f1-3)
TITLE=$(echo "$BASENAME" | cut -d'-' -f4-)
POST_NAME="${DATE}-${TITLE}.md"
ASSETS_DIR="/assets/${BASENAME}_files"

# Step 1: Convert the Jupyter Notebook to Markdown
jupyter nbconvert --to markdown "$NOTEBOOK"

# Step 2: Move the converted Markdown file to the _posts directory
mv "${BASENAME}.md" "../_posts/${POST_NAME}"

# Step 3: Remove the existing assets directory if it exists and move the new one
if [ -d "../assets/${BASENAME}_files" ]; then
  rm -rf "../assets/${BASENAME}_files"
fi
mv "${BASENAME}_files" "../assets/"

# Step 4: Add front matter to the Markdown file
FRONT_MATTER="---
layout: post
title: \"${TITLE//-/ }\"
date: ${DATE}
---"

# Create a temporary file with the front matter and the content of the Markdown file
echo -e "${FRONT_MATTER}\n\n$(cat "../_posts/${POST_NAME}")" > "../_posts/${POST_NAME}.tmp"

# Replace the original Markdown file with the temporary file
mv "../_posts/${POST_NAME}.tmp" "../_posts/${POST_NAME}"

# Step 5: Update the links in the Markdown file
sed -i "s|${BASENAME}_files|${ASSETS_DIR}|g" "../_posts/${POST_NAME}"

echo "Notebook ${NOTEBOOK} has been converted and moved to ../_posts/${POST_NAME}"
```

