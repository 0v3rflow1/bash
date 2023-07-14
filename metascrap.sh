#! /bin/bash

metaScrap(){
	usage="Usage: $0 <uid|uname|threadCode>";
    if [ $# -ne 1 ]; then
        echo $usage;
        return 1;
    fi;

	target=$1;
	patternUID="^[0-9]+$";
	patternUname="^[a-z0-9\_]+$";
	patternCodePost="^[a-Z0-9\_]+$";
	if [[ $target =~ $patternUID ]]; then
	
		uid=$target;
		echo "Procesando el uid: $target";
		getFromThreadsDotNet $uid;
		
	elif [[ $target =~ $patternUname ]]; then
	
		uname=$target;
		echo "Procesando el username: $target";
		getFromInstagramDotCom $uname;

	elif [[ $target =~ $patternCodePost ]]; then
	
		threadCode="${target:1}";
		echo "Procesando el threadCode: $threadCode";
		threadId=$(getThreadIdByThreadCode $threadCode);
		getThread $threadId;
		
	else
		echo $usage;
	fi
}

getFromInstagramDotCom(){
	uname=$1;
	rjson=`curl -s "https://www.instagram.com/api/v1/users/web_profile_info/?username={$uname}"  -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36' -H 'x-ig-app-id: 936619743392459' --compressed|python -m json.tool`;
	echo "$rjson";
}

getFromThreadsDotNet(){
	uid=$1;
	rjson=`curl -s 'https://www.threads.net/api/graphql' -H 'sec-fetch-site: same-origin' -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36' -H 'x-fb-lsd: xxazHOmBpxtcEWhw1wCMxx' -H 'x-ig-app-id: 238260118697367' --data-raw "lsd=xxazHOmBpxtcEWhw1wCMxx&variables=%7B%22userID%22%3A%22"$uid"%22%7D&server_timestamps=true&doc_id=23996318473300828" --compressed|python -m json.tool`;
	echo "$rjson";
}

getThreadIdByThreadCode(){
	threadCode=$1;
	r=$(curl -s 'https://www.threads.net/t/CupSoLsgyoc' \
  -H 'authority: www.threads.net' \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: es-419,es;q=0.9' \
  -H 'cache-control: max-age=0' \
  -H 'sec-ch-prefers-color-scheme: light' \
  -H 'sec-ch-ua: "Not.A/Brand";v="8", "Chromium";v="114"' \
  -H 'sec-ch-ua-full-version-list: "Not.A/Brand";v="8.0.0.0", "Chromium";v="114.0.5735.198"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Linux"' \
  -H 'sec-ch-ua-platform-version: "6.1.38"' \
  -H 'sec-fetch-dest: document' \
  -H 'sec-fetch-mode: navigate' \
  -H 'sec-fetch-site: same-origin' \
  -H 'sec-fetch-user: ?1' \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36' \
  -H 'viewport-width: 1024' \
  --compressed);
  echo $r|grep -Eio "post_id\":\"[0-9]*"|grep -Eio "[0-9]*"|uniq;
}

getThread(){
	threadId=$1;
	rjson=$(curl -s 'https://www.threads.net/api/graphql' -H 'sec-fetch-site: same-origin' -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36' -H 'x-fb-lsd: xxazHOmBpxtcEWhw1wCMxx' -H 'x-ig-app-id: 238260118697367' --data-raw "lsd=xxazHOmBpxtcEWhw1wCMxx&variables=%7B%22postID%22%3A%22"$threadId"%22%7D&server_timestamps=true&doc_id=6254373924615707" --compressed|python -m json.tool);
	echo "$rjson";
}

metaScrap $@;
