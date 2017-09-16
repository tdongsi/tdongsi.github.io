---
layout: post
title: "Keep Gruntfile clean with load-grunt-config"
date: 2017-09-15 23:29:17 -0700
comments: true
categories: 
- Javascript
- Grunt
---

In this post, we look into how to keep our Gruntfile clean and tidy.
By keeping our Gruntfile clean and tidy, it is easier for us to refine and improve the Grunt build process with its numerous plugins.

<!--more-->

### Starting point

Let's say you start a new Node project.

``` plain Starting a Node project
# Init by creating package.json file
npm init
# Answer questions to create package.json file

# Adding grunt
npm install grunt --save-dev
npm install grunt-jslint --save-dev
npm install load-grunt-tasks --save-dev

# Initalizing Gruntfile
npm install grunt-init -g
grunt-init gruntfile
# grunt-init node
```

At the end of these steps, you have a basic `package.json` and `Gruntfile`.
The basic Gruntfile would appear like this:

``` javascript Basic Gruntfile
/*global module:false*/
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    // Metadata.
    pkg: grunt.file.readJSON('package.json'),
    banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
      '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
      '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
      '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
      ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n',
    // Task configuration.
    concat: {
      options: {
        banner: '<%= banner %>',
        stripBanners: true
      },
      dist: {
        src: ['lib/<%= pkg.name %>.js'],
        dest: 'dist/<%= pkg.name %>.js'
      }
    },
    uglify: {
      options: {
        banner: '<%= banner %>'
      },
      dist: {
        src: '<%= concat.dist.dest %>',
        dest: 'dist/<%= pkg.name %>.min.js'
      }
    },
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        unused: true,
        boss: true,
        eqnull: true,
        browser: true,
        globals: {}
      },
      gruntfile: {
        src: 'Gruntfile.js'
      },
      lib_test: {
        src: ['lib/**/*.js', 'test/**/*.js']
      }
    },
    qunit: {
      files: ['test/**/*.html']
    },
    watch: {
      gruntfile: {
        files: '<%= jshint.gruntfile.src %>',
        tasks: ['jshint:gruntfile']
      },
      lib_test: {
        files: '<%= jshint.lib_test.src %>',
        tasks: ['jshint:lib_test', 'qunit']
      }
    }
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-qunit');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-watch');

  // Default task.
  grunt.registerTask('default', ['jshint', 'qunit', 'concat', 'uglify']);

};
```

### `load-grunt-tasks` plugin

In the original basic Gruntfile, we have to manually load our Grunt plugins, as

``` javascript
grunt.loadNpmTasks('grunt-contrib-concat');
grunt.loadNpmTasks('grunt-contrib-uglify');
grunt.loadNpmTasks('grunt-contrib-imagemin');
```

If you now uninstall the plugin via `npm` and update your `package.json`, but forget to update your `Gruntfile`, your build will break.
With `load-grunt-tasks` plugin, you can collapse that down to the following one-liner:

``` javascript
require('load-grunt-tasks')(grunt);
```

After requiring the plugin, it will analyze your package.json file, determine which of the dependencies are Grunt plugins and load them all automatically.

### `load-grunt-config` plugin

`load-grunt-tasks` shrunk your Gruntfile in code and complexity a little, but task configurations still remain in the Gruntfile (defined in `grunt.initConfig`). 
As you configure a large application, it will still become a very large file.

This is when `load-grunt-config` comes into play. 
`load-grunt-config` lets you break up your Gruntfile config by task.
With `load-grunt-config`, your `Gruntfile` may look like this:

``` javascript Gruntfile with load-grunt-config
module.exports = function(grunt) {

  var path = require('path');  
  const appOptions = {
      data: {},
      configPath: [
          path.join(process.cwd(), '/grunt/tasks')
      ]
  };
  
  require('time-grunt')(grunt);
  require('load-grunt-config')(grunt, appOptions);

};
```

Note that `load-grunt-config` also includes `load-grunt-tasks`'s functionality.
The task configurations live in files in folder `./grunt/tasks`.
By default, `./grunt` folder is used but, in this example, using a custom path is demonstrated.
In other words, our directory structure should be like this:

``` plain Directory structure
- current_project/
-- Gruntfile
-- grunt/tasks/
---- concat.js
---- uglify.js
---- imagemin.js
```

The task configuration for each task is defined in respective file name.
For example, task `concat` is defined in "grunt/tasks/concat.js":

``` javascript grunt/tasks/concat.js
module.exports = {
  options: {
    banner: '<%= banner %>',
    stripBanners: true
  },
  dist: {
    src: ['lib/<%= pkg.name %>.js'],
    dest: 'dist/<%= pkg.name %>.js'
  }
};
```

The list of registered task aliases such as `default` is defined in `aliases.js` file.

``` javascript grunt/tasks/aliases.js
module.exports = function(grunt, appOptions) {
    var buildList = [
        'jshint',
        'qunit',
        'concat',
        'uglify'
    ];

    return {
        default: ['build'],
        build: buildList,
        test: ['jslint']
    };
};
```

### References

* Safari: Introducing Grunt: the JavaScript task runner
* Common Grunt plugins:
    * [load-grunt-config](http://firstandthird.github.io/load-grunt-config/): key plugin to keep Gruntfile organized.
    * [concat](https://www.npmjs.com/package/grunt-contrib-concat)
    * Unit Testing: [qunit](https://www.npmjs.com/package/grunt-contrib-qunit)
    * Image optimization: imagemin
    * Deploying: deploy
    * Chaining: concurrent
* [Project scaffolding with `grunt-init`](https://gruntjs.com/project-scaffolding)
    * grunt-init-commonjs - Create a commonjs module, including Nodeunit unit tests.
    * grunt-init-gruntfile - Create a basic Gruntfile.
    * grunt-init-gruntplugin - Create a Grunt plugin, including Nodeunit unit tests.
    * grunt-init-jquery - Create a jQuery plugin, including QUnit unit tests.
    * [grunt-init-node](https://github.com/gruntjs/grunt-init-node) - Create a Node.js module, including Nodeunit unit tests.


