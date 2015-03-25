latex input:    mmd-article-header
Title:          SQL Notes
Author:         Ethan C. Petuchowski
Base Header Level:  1
latex mode:     memoir
Keywords:       SQL, Programming Language, Syntax, Databases
CSS:            http://fletcherpenney.net/css/document.css
xhtml header:   <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
copyright:      2014 Ethan C. Petuchowski
latex input:    mmd-natbib-plain
latex input:    mmd-article-begin-doc
latex footer:   mmd-memoir-footer


### Make Up Your Own Table ("Scalar Query") ###

	SELECT 'q' as docid, 'treasury' as term, 1 as count

Creates the database row

| docid | term | count |
| :------: | :------: | :------: |
| q | treasury |  1 |

as a standalone row.

### Unique vs Distinct

[From StackOverflow](http://stackoverflow.com/questions/336268/sql-difference-between-select-unique-and-select-distinct)

* **`Unique`** is a keyword used in the **`Create Table()`** directive
  * to denote that a field will contain unique data
  * usually used for natural keys, foreign keys etc.
* **`Distnct`** is used in the **`Select`** statement to notify the query that
  you only want the unique items returned when a field holds data that may not
  be unique.

### Foreign Keys

Sample (PostgreSQL) Code for creating a Foreign Key

    videos_id varchar CONSTRAINT FK_videos_id
    references videos(id)
    match simple
    on update cascade
    on delete cascade

or simply

    ALTER TABLE bar add FOREIGN KEY (id) references foo(id);

According to the [Docs](http://www.postgresql.org/docs/8.3/static/ddl-constraints.html#DDL-CONSTRAINTS-FK)
(which look very well-done in general):

They are by default

* Allowed to be NULL
* `MATCH SIMPLE` --- allows some foreign key columns (of a multiple column FK)
  to be null while other parts of the foreign key are not null.
* `on (UPDATE|DELETE) no action` ---  if any referencing rows still exist when
  the constraint is checked, an error is raised

Though you can also do

* `MATCH FULL` --- doesn't allow one column of a multicolumn foreign key to be
  null unless all foreign key columns are null.
* `on (UPDATE|DELETE)` --- action possibilities are the same for both
    * `restrict` --- prevent deletion of a referenced row
        * The essential difference between these `no action` and `restrict` is
          that `NO ACTION` allows the check to be deferred until later in the
          transaction, whereas `RESTRICT` does not.
    * `cascade` --- when a referenced row is deleted, row(s) referencing it
      should be automatically deleted as well.
    * `set (NULL|DEFAULT)` --- update value to this value when referenced row
      is deleted
        * Note that these do not excuse you from observing any `constraints`.
          For example, if an action specifies `SET DEFAULT` but the `default`
          value would not satisfy the `foreign key`, the operation will fail.

### NULL

* By default, values are allowed to be `NULL`
* You can prevent this by saying

        price numeric NOT NULL CHECK (price > 0)

* You may also want to specify that it *can* be `NULL` by saying

        price numeric NULL


> *Tip:* In most database designs *the majority of columns should be marked*
> `NOT NULL`.
