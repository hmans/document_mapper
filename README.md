# Document Mapper

[![Build Status](https://secure.travis-ci.org/ralph/document_mapper.png)](http://travis-ci.org/ralph/document_mapper)

Document mapper is an object mapper for plain text documents. The documents look like the ones used in [jekyll](http://github.com/mojombo/jekyll), [toto](http://github.com/cloudhead/toto) or [Serious](http://github.com/colszowka/serious). They consist of a preambel written in YAML (also called YAML front matter), and some content in the format you prefer, e.g. Textile. This enables you to write documents in your favorite editor and access the content and metadata in your Ruby scripts.


## Step-by-step tutorial

Documents look somehow like this. The part between the ```---```s is the YAML front matter. After the second ```---```, there is one blank line, followed by the content of the file. All items in the YAML front matter and the content are accessible by Document Mapper.

```yaml
---
id: 1
title: Ruby is great
tags: [programming, software]
number_of_foos: 42
status: published
---

I like Ruby.
```


In order to access the values in the front matter, you have to create a class that includes ```DocumentMapper::Document``` as well as your preferred store mixin.

```ruby
require 'document_mapper'
class MyDocument
  include DocumentMapper::Document
  include DocumentMapper::FilesystemStore
end
```

### Initializing single documents

```ruby
doc = MyDocument.load('./documents/document-file.textile')
```


### Accessing the attributes of single documents

```ruby
doc.title                    # => "Ruby is great"
doc.tags                     # => ["programming", "software"]
doc.content                  # => "I like Ruby."
```


### Date recognition

You can either set the date of a document in the YAML front matter, or you can use the file name, if you want to. A file named ```2010-08-07-test-document-file.textile``` will return a date like this:

```ruby
doc.date                     # => #<Date: 2010-08-07 (4910833/2,0,2299161)>
doc.date.to_s                # => "2010-08-07"
doc.year                     # => 2010
doc.month                    # => 08
doc.day                      # => 07
```


### Working with directories

As an example let's assume we have a directory called "documents" containing the following files:

```ruby
documents/
|-foo.textile
|-bar.textile
```


In order to work with a whole directory of files, we have to use the @directory@ method:

```ruby
require 'document_mapper'
class MyDocument
  include DocumentMapper::Document
  self.directory = 'documents'
end
```

Now we can receive all available documents or filter like that:

```ruby
MyDocument.all
MyDocument.first
MyDocument.last
MyDocument.limit(2)
MyDocument.offset(2)
MyDocument.where(:title => 'Some title').first
MyDocument.where(:status => 'published').all
MyDocument.where(:year => 2010).all
```

Not all of the documents in the directory need to have all of the attributes. You can add single attributes to single documents, and the queries will only return those documents where the attributes match.

The document queries do support more operators than just equality. The following operators are available:

```ruby
MyDocument.where(:year.gt => 2010)        # year > 2010
MyDocument.where(:year.gte => 2010)       # year >= 2010
MyDocument.where(:year.in => [2010,2011]) # year one of [2010,2011]
MyDocument.where(:tags.include => 'ruby') # 'ruby' is included in tags = ['ruby', 'rails', ...]
MyDocument.where(:year.lt => 2010)        # year < 2010
MyDocument.where(:year.lte => 2010)       # year <= 2010
```

While retrieving documents, you can also define the way the documents should be ordered. By default, the documents will be returned in the order they were loaded from the file system, which usually means by file name ascending. If you define an ordering, the documents that don't own the ordering attribute will be excluded.

```ruby
MyDocument.order_by(:title => :asc).all  # Order by title attribute, ascending
MyDocument.order_by(:title).all          # Same as order_by(:title => :asc)
MyDocument.order_by(:title => :desc).all # Order by title attribute, descending
```


### Chaining

Chaining works with all available query methods, e.g.:

```ruby
MyDocument.where(:status => 'published').where(:title => 'Some title').limit(2).all
```


### Reloading

If any of the files change, you must manually reload them:

```ruby
MyDocument.reload
```


## Author

Written by [Ralph von der Heyden](http://www.rvdh.de). Don't hesitate to contact me if you have any further questions.

Follow me on [Twitter](http://twitter.com/ralph)
