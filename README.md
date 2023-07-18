# openresty docker image

## Added features

### s3 presigned url generation

1. Run the container:
```shell
docker run --name test -e AWS_ACCESS_KEY_ID='xxxxxx' -e AWS_SECRET_ACCESS_KEY='xxxxxx' -e S3_BUCKET_NAME='xxxxxxx' -e AWS_S3_ENDPOINT='s3.amazonaws.com' -e AWS_S3_REGION='us-northeast-1' macrozhao/openresty
```

2. To use this feature, you need to configure your `nginx.conf` like belowings:
```
    server {
        location /test.txt {
            content_by_lua_block {
                local s3_client = require "resty.aws_s3.client"
                local client, err, msg = s3_client.new(os.getenv("AWS_ACCESS_KEY_ID"),
                                                       os.getenv("AWS_SECRET_ACCESS_KEY"),
                                                       os.getenv("AWS_S3_ENDPOINT"),
                                                       os.getenv("AWS_S3_REGION"))
                if err ~= nil then
                    ngx.say('failed to new s3_client')
                    ngx.exit(ngx.HTTP_OK)
                end

                local presigned_url, err, msg = client:generate_presigned_url(
                        'get_object', {Bucket=os.getenv("S3_BUCKET_NAME"), Key=ngx.var.uri},
                        {ExpiresIn=3600, https=true})
                if err ~= nil then
                    ngx.say('failed to genearte presigned get object url')
                    ngx.exit(ngx.HTTP_OK)
                end

                ngx.say('presigned download url: ' .. presigned_url)
                
            }
        }
    }
```

3. Test url generation
```
docker exec -it test bash
curl -L http://localhost:8080/test.txt
```