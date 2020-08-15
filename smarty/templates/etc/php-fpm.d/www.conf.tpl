{* Smarty *}
[www]

listen = 9000
access.log = /proc/self/fd/2
chdir = /var/www/html
catch_workers_output = yes

; Process manager options
pm = {$smarty.env.PHP_FPM_PM}
pm.max_children = {$smarty.env.PHP_FPM_MAX_CHILDREN}
pm.start_servers = {$smarty.env.PHP_FPM_START_SERVERS}
pm.min_spare_servers = {$smarty.env.PHP_FPM_MIN_SPARE_SERVERS}
pm.max_spare_servers = {$smarty.env.PHP_FPM_MAX_SPARE_SERVERS}
pm.max_requests = {$smarty.env.PHP_FPM_MAX_REQUESTS}
pm.process_idle_timeout = 30s;
pm.status_path = /status

ping.path = /ping
ping.response = pong

php_admin_value[variables_order] = "GPCS"
php_admin_value[post_max_size] = {$smarty.env.PHP_POST_MAX_SIZE}
php_admin_value[upload_max_filesize] = {$smarty.env.PHP_UPLOAD_MAX_FILESIZE}
php_admin_value[max_file_uploads] = {$smarty.env.PHP_MAX_FILE_UPLOADS}

{if isset($smarty.env.REDIS_HOST) }
    php_value[session.save_handler] = redis
    php_value[session.save_path] = {strip}"tcp://{$smarty.env.REDIS_HOST}
    :{if isset($smarty.env.REDIS_PORT)}{$smarty.env.REDIS_PORT}{else}6379{/if}
    {if isset($smarty.env.REDIS_HOST_PASSWORD)}?auth={$smarty.env.REDIS_HOST_PASSWORD}{/if}
    "{/strip}
{else}
    php_value[session.save_handler] = files
    php_value[session.save_path] = "/tmp/php/session"
{/if}

php_value[session.use_strict_mode] = 1
php_value[session.use_cookies] = 1
;php_value[session.cookie_secure] =
php_value[session.use_only_cookies] = 1
php_value[session.name] = PHPSESSID

php_value[soap.wsdl_cache_enabled]=1
php_value[soap.wsdl_cache_dir]="/tmp/php/wsdlcache"
php_value[soap.wsdl_cache_ttl]=86400
php_value[soap.wsdl_cache_limit] = 5
