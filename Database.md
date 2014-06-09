# Queries by View

## Index
`SELECT id, taken_at, thumb_data, DATE_TRUNC(taken_at) AS year FROM photos`
*Note: May need to be sharded/paginated*

## Period/Year
`SELECT id, DATE_TRUNC(taken_at), thumb_data FROM photos WHERE year='#{year}'`
OR
`SELECT id, thumb_data FROM photos WHERE id in (#{ids_for_year})`
*Note: May want to not use thumbs for medium because of memory constrants
(would require thumbs to be larger)*

## Detail/Show
`SELECT id, taken_at, url, tags FROM photos WHERE id=#{id}`
*Note: Want pretty much everything except medium/thumb_data*

## Upload/Create
`INSERT INTO photos(...) VALUES (...)`

## Change Tags
`INSERT INTO tags...`
`INSERT INTO taggings...`
*Note: First is optional`

## Sync DB
`INSERT REPLACE INTO photos(...) VALUES (...)`

