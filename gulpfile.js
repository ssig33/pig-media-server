var gulp = require('gulp');
var browserify = require('browserify');
var babelify = require('babelify');
var source = require('vinyl-source-stream');
var uglify = require('gulp-uglify');
var buffer = require('vinyl-buffer');
var cssDir = 'stylesheets'

gulp.task('browserify', function() {
  browserify('./javascripts/application.js', { debug: true })
    .transform(babelify)
    .bundle()
    .on("error", function (err) { console.log("Error : " + err.message); })
    .pipe(source('bundle.js'))
    .pipe(gulp.dest('./lib/pig-media-server/views/'))
});

gulp.task('build', function(){
  browserify('./javascripts/application.js', { debug: true })
    .transform(babelify)
    .bundle()
    .on("error", function (err) { console.log("Error : " + err.message); })
    .pipe(source('bundle.js'))
    .pipe(buffer())
    .pipe(uglify())
    .pipe(gulp.dest('./lib/pig-media-server/views/'))

});


gulp.task('watch', ['browserify'], function(){
  gulp.watch('./javascripts/**/*.js', ['browserify']);
});
