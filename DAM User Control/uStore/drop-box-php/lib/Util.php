<?php

class Util
{
    public static function fetchImg($url)
    {
        $url = str_replace("&#39;", "", $url);

        $fileNameParts = explode("/", $url);
        $fileName = $fileNameParts[count($fileNameParts)-1];

        $str = file_get_contents($url);

        if($str)
        {
            $fp = fopen(Config::ASSET_SOURCE_PATH.$fileName,'w');
            fwrite($fp, $str);
            fclose($fp);

            //copy file to ftp

            $ftpBroker = new FTPBroker(Config::UPRODUCE_FTP_HOST, Config::UPRODUCE_FTP_USER
                                       , Config::UPRODUCE_FTP_PASS, Config::UPRODUCE_FTP_PORT
                                       , Config::UPRODUCE_FTP_TIMEOUT);

           
            $ftpBroker->transferFile(Config::UPRODUCE_FTP_ASSET_SOURCE_PATH.$fileName
                                    , Config::ASSET_SOURCE_PATH.$fileName);

            //delete local file
            unlink(Config::ASSET_SOURCE_PATH.$fileName);
        }
        else
            throw new Exception("Missing Image: ".$url);
    }
    
    public static function fetchImgAsynch($response, $url, $request_info, $user_data, $time)
    {
        $fileNameParts = explode("/", $url);
        $fileName = $fileNameParts[count($fileNameParts)-1];

        if($response)
        {
            try {
                
                $fp = fopen(Config::ASSET_SOURCE_PATH.$fileName,'w');
                fwrite($fp, $response);
                fclose($fp);

                //copy file to ftp

                $ftpBroker = new FTPBroker(Config::UPRODUCE_FTP_HOST, Config::UPRODUCE_FTP_USER
                                           , Config::UPRODUCE_FTP_PASS, Config::UPRODUCE_FTP_PORT
                                           , Config::UPRODUCE_FTP_TIMEOUT);


                $ftpBroker->transferFile(Config::UPRODUCE_FTP_ASSET_SOURCE_PATH.$fileName
                                        , Config::ASSET_SOURCE_PATH.$fileName);

                //delete local file
                unlink(Config::ASSET_SOURCE_PATH.$fileName);
                
            } catch (Exception $ex) {
                
                
            }
        }
    }
    
    public static function postRequest($target_url,array $post)
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL,$target_url);
        curl_setopt($ch, CURLOPT_POST,1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $post);
        curl_setopt($ch, CURLOPT_USERAGENT , "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); //Set curl to return the data instead of printing it to the browser.
        curl_setopt($ch, CURLOPT_USERAGENT , "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)");
        $result=curl_exec ($ch);
        curl_close ($ch);
        
        return $result;
    }
    
    public static function getRequest($url,array $data,$auth=null)
    {
        if( count($data) > 0 )
        {
            //url-ify the data for the get  : Actually create datastring
            $fields_string = '';

            foreach($data as $key=>$value)
            {
                $fields_string[] = $key.'='.urlencode($value).'&';
            }

            $urlStringData = $url.'?'.implode('&',$fields_string);
        }
        else
        {
            $urlStringData = $url;
        }

        $ch = curl_init();

        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); //Set curl to return the data instead of printing it to the browser.
        curl_setopt($ch, CURLOPT_USERAGENT , "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)");
        curl_setopt($ch, CURLOPT_URL, $urlStringData ); #set the url and get string together
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        
        if( $auth != null )
        {
            curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_ANY);
            curl_setopt($ch, CURLOPT_USERPWD, $auth);
        }
        
        $return = curl_exec($ch);
        curl_close($ch);

        return $return;
    }
    
    public static function deleteRequest($url,array $data)
    {
        //url-ify the data for the get  : Actually create datastring
        $fields_string = '';

        foreach($data as $key=>$value)
        {
            $fields_string[] = $key.'='.urlencode($value).'&';
        }
        
        $urlStringData = $url.'?'.implode('&',$fields_string);

        $ch = curl_init();

        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); //Set curl to return the data instead of printing it to the browser.
        curl_setopt($ch, CURLOPT_USERAGENT , "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)");
        curl_setopt($ch, CURLOPT_URL, $urlStringData ); #set the url and get string together

        $return = curl_exec($ch);
        curl_close($ch);

        return $return;
    }
    
    public static function objToArray($obj,$returnProperties,array $exclusions)
    {
        $result = array();

        foreach($obj as $prop => $value)
        {
            $includeValue = true;

            foreach($exclusions as $exclusion)
            {
                if($prop == $exclusion)
                    $includeValue = false;
            }

            if($includeValue)
            {
                if($returnProperties)
                    $result[] = $prop;
                else
                    $result[] = $value;
            }
        }

        return $result;
    }

    public static function stripChar($input,$char)
    {
        if( is_array($input) )
        {
            foreach($input as $key => $value)
            {
                $input[$key] = str_replace($char,"",$value);
            }
        }
        else
          $input = str_replace($char, "", $input);

        return $input;
    }

    public static function serialise($input,$obj)
    {
        if( is_array($input) )
        {
            foreach($input as $key => $value)
            {
                $input[$key] = Util::stdClassToObj($value, $obj);
            }
        }
        else
            $input = Util::stdClassToObj($input, $obj);

        return $input;
    }

    private static function stdClassToObj(stdClass $stdClass,$obj)
    {
        $newObj = clone $obj;

        foreach($stdClass as $prop => $value)
        {
            $newObj->$prop = $value;
        }

        return $newObj;
    }
}

?>