module.exports = function (eleventyConfig) {
  eleventyConfig.setUseGitIgnore(false)
  eleventyConfig.addPassthroughCopy('CNAME')
  eleventyConfig.addPassthroughCopy({
    'node_modules/@fortawesome/fontawesome-free/webfonts': 'fonts/fontawesome'
  })
  eleventyConfig.setTemplateFormats([
    'html',
    'md',
    'njk',
    'css',
    'jpg',
    'map',
    'svg'
  ])
  eleventyConfig.setFrontMatterParsingOptions({
    excerpt: function (file, options) {
      if (file.data.layout === 'article') {
        file.excerpt = file.content.split('\n\n')[0]
      }
    }
  })
}
