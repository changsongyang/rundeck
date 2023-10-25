#!/bin/bash

#test DELETE /api/45/project/NAME
#using API v45, no xml result wrapper

# use api V45
API_VERSION=45

DIR=$(cd `dirname $0` && pwd)
source $DIR/include.sh

test_proj="APIDeleteTest"

# now submit req
runurl="${APIURL}/projects"

echo "TEST: DELETE /api/45/project/${test_proj}?deferred=false"

##
#SETUP: create project
##

cat > $DIR/proj_create.post <<END
{
    "name":"$test_proj",
    "description":"test1",
    "config":{
        "test.property":"test value"
    }
}
END

# get listing
docurl -X POST -D $DIR/headers.out --data-binary @$DIR/proj_create.post -H Content-Type:application/json ${runurl}?${params} > $DIR/curl.out
if [ 0 != $? ] ; then
    errorMsg "ERROR: failed POST request"
    exit 2
fi
assert_http_status 201 $DIR/headers.out

$SHELL $SRC_DIR/api-test-success.sh $DIR/curl.out || exit 2

#Check result
assert_json_value "$test_proj" ".name" $DIR/curl.out


##
#TEST: delete project
##

runurl="${APIURL}/project/${test_proj}?deferred=false"

# get listing
docurl -D $DIR/headers.out -X DELETE ${runurl} > $DIR/curl.out
if [ 0 != $? ] ; then
    errorMsg "ERROR: failed DELETE request"
    exit 2
fi
assert_http_status 204 $DIR/headers.out


echo "OK"


rm $DIR/proj_create.post
rm $DIR/curl.out
rm $DIR/headers.out

