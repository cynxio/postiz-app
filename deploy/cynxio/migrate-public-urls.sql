-- Run once on the restored VPS database, after taking the migration backup.
BEGIN;
UPDATE "Integration"
SET picture = 'https://social.internal.cynxio.com/' || substr(picture, length('http://localhost:4007/') + 1)
WHERE picture LIKE 'http://localhost:4007/%';
UPDATE "Media"
SET path = 'https://social.internal.cynxio.com/' || substr(path, length('http://localhost:4007/') + 1)
WHERE path LIKE 'http://localhost:4007/%';
UPDATE "Media"
SET thumbnail = 'https://social.internal.cynxio.com/' || substr(thumbnail, length('http://localhost:4007/') + 1)
WHERE thumbnail LIKE 'http://localhost:4007/%';
COMMIT;
