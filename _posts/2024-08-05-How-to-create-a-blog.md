---
layout: post
title:  "How to publish your jupyter notebooks on github pages"
date:   2024-08-05
---

In this blog I briefly go over my setup of how I created my blog using github pages and jekyll. I also describe how I automated the process of publishing jupyter notebooks directly as a blog post on this blog. Hope this helps anyone, who struggled with the setup as I did in the beginning ;)

# Create github pages

1. Create github repository
	1. Make it public
	2. Default name: \<username\>.github.io
2. Go to settings -> Pages and select a branch (choose the main branch as a default) to deploy your webpage
3. Create a 'index.html' file in your repository with the following content

```html
<!DOCTYPE html>

<html>
	<head>
	    <title>Hello, World!</title>
	</head>
	
	<body>
	    <h1>Hello, World!</h1>
	</body>

</html>
```

**voilà le website! But it's ugly as hell.** Now you have to options here: Code everything yourself in the website, creating a full html/css/javascript webpage from scratch, or use a website builder like jekyll.
4. Setting up [jekyll](https://jekyllrb.com/docs/github-pages/)
	1. I run on WSL, so there could be some differences, but in principle, this setup should work for ubuntu as well as WSL users.

# Setting up Jekyll on Github Pages

Installing the prerequisits
```bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt install ruby-full
sudo apt-get install make gcc gpp build-essential zlib1g zlib1g-dev ruby-dev dh-autoreconf
sudo gem update
gem install jekyll bundler
```

Setting up the jekyll blog
```bash
jekyll new path/to/cloned/reop
cd path/to/cloned/repo
bundle install
bundle exec jekyll serve --livereload
```

Your blog is now up and running. Just writing markdown blogposts in the \_posts' folder will get you new articles on the blog page. To have them publicly available, you will need to push them to the github repo branch you declared in the beginning (main by default). They will then (after some short time delay) be available on your blog page \<username\>.github.io.


# Publishing Jupyter Notebooks

Jupyter has the nice functionality to convert its notebooks into markdown files. This is very handy for programming projects, where I want to have some combination of text, images, code and output of the code visible in the blog. I therefore wanted to automate the publishing process of jupyter notebooks on the blog. I wrote a little shell script, that takes any given .ipynb file and converts it into markdown, moves it into the "\_posts" folder and and prepends the front matter to the markdown file. Additionally, it moves all the assets needed for the displaying of the markdown file to the corresponding folders and updates the paths in the markdown file. 
All of this means, that I can now just focus on writing my blog as a jupyter notebook and then run the shell script below to directly publish this notebook as a blogpost. Maybe this little setup helps you as well. 

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
