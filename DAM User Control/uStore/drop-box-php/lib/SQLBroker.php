<?php

/**
 * Hoyts Workflow - class.SQLBroker.php
 *
 */

class SQLBroker
{
    private $pdoHandle;

    private static $sqlConnection;

    // --- OPERATIONS ---
    public static function getSQLConnection()
    {
        if( SQLBroker::$sqlConnection == null )
            SQLBroker::$sqlConnection = new SQLBroker();

        return SQLBroker::$sqlConnection;
    }

    public function SQLBroker($database = null)
    {
        $this->pdoHandle = $this->createPdoHandle($database);
    }
    
    public function createPdoHandle($database=null)
    {
        if($database == null)
            $database = Config::SQL_DB;
        
        if(Config::SQL_SERVER_TYPE == 'mssql')
            $pdoHandle = new PDO("odbc:Driver={SQL Server};Server=".Config::SQL_HOST.",".Config::SQL_PORT.";Database=".$database.";",  Config::SQL_USER,  Config::SQL_PASS);
        else
            $pdoHandle = new PDO("mysql:host=".Config::SQL_HOST.";port=".Config::SQL_PORT.";dbname=".$database,  Config::SQL_USER,  Config::SQL_PASS);
       
        $pdoHandle->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        return $pdoHandle;
    }
    
    public function select(array $fieldNames,$tableName,array $conditionFields,array $conditionValues,$orderBy=null)
    {
        $result = null;

        //Sanatise Inputs
        $fieldNames = Util::stripChar($fieldNames, "'");
        $tableName = Util::stripChar($tableName, "'");
        $conditionFields = Util::stripChar($conditionFields, "'");

        $query = "SELECT ".implode(",", $fieldNames)." FROM ".$tableName."";

        if( count($conditionFields) > 0 && count($conditionFields) == count($conditionValues) )
        {
            $query .= " WHERE ".implode(" = ? AND ", $conditionFields);
            $query .= " = ?";
        }
        
        if($orderBy != null)
            $query .= " ORDER BY ".$orderBy;

        $stmt = $this->pdoHandle->prepare($query);
        if ( $stmt->execute($conditionValues) )
        {
            $result = array();

            while( $pdoResult = $stmt->fetch(PDO::FETCH_ASSOC) )
            {
                $obj = new stdClass();

                foreach($fieldNames as $fieldName)
                {
                   $obj->$fieldName = $pdoResult[$fieldName];
                }

                $result[] = $obj;
            }
        }

        return $result;
    }
    
    public function selectQuery($query)
    {
        $result = null;
        
        $stmt = $this->pdoHandle->prepare($query);
        if ( $stmt->execute() )
        {
            $result = array();

            while( $pdoResult = $stmt->fetch(PDO::FETCH_ASSOC) )
            {
                $obj = new stdClass();

                foreach($pdoResult as $fieldName => $value)
                {
                   $obj->$fieldName = $pdoResult[$fieldName];
                }

                $result[] = $obj;
            }
        }

        return $result;
    }
   
    public function runQuery($query,$values)
    {
        $stmt = $this->pdoHandle->prepare($query);
        if ( $stmt->execute($values) )
            return true;
        else
            return false;
    }
    
    public function insert(array $fieldNames,array $values,$tableName)
    {
        $result = false;

        //Sanatise Inputs
        $fieldNames = Util::stripChar($fieldNames, "'");
        $tableName = Util::stripChar($tableName, "'");
        
        foreach($values as $key => $val)
        {
            if(Config::SQL_SERVER_TYPE == 'mssql')
                $values[$key] = str_replace("'", "''", $val);
            else
                $values[$key] = str_replace("'", "\'", $val);;
            $values[$key] = "'".$values[$key]."'";
        }
        
        if( count($fieldNames) == count($values) )
        {
            $query = "INSERT INTO ".$tableName." (".implode(",", $fieldNames).") VALUES 
                (".implode(",", $values).")";

            $stmt = $this->pdoHandle->prepare($query);
            if ( $stmt->execute($values) )
                $result = true;
        }

        return $result;
    }


    private function removeTableById($id,$table)
    {
        $fields = array("uid");
        $values = array($id);
        return $this->delete($fields, $values, $table);
    }

    public function delete(array $fieldNames,array $values,$tableName)
    {
        $result = null;

        //Sanatise Inputs
        $fieldNames = Util::stripChar($fieldNames, "'");
        $tableName = Util::stripChar($tableName, "'");

        if( count($fieldNames) > 0 && count($fieldNames) == count($values) )
        {
            $query = "DELETE FROM ".$tableName." WHERE ".implode(" = ? AND ", $fieldNames)." = ?";

            $stmt = $this->pdoHandle->prepare($query);
            if ( $stmt->execute($values) )
                $result = true;
        }

        return $result;
    }

    
    private function updateTableById($id,$tableName,$fieldNames, $values)
    {
        $conditionFields = array("uid");
        $conditionValues = array($id);
        return $this->update($fieldNames, $values, $tableName, $conditionFields, $conditionValues);
    }

    private function update(array $fieldNames,array $values,$tableName,array $conditionFields,array $conditionValues)
    {
        $result = null;

        //Sanatise Inputs
        $fieldNames = Util::stripChar($fieldNames, "'");
        $tableName = Util::stripChar($tableName, "'");
        $conditionFields = Util::stripChar($conditionFields, "'");

        if( count($values) >= count($fieldNames)  )
        {
            $query = "UPDATE ".$tableName." SET ".implode(" = ?, ", $fieldNames)." = ?";

            if( count($conditionFields) > 0 && count($conditionFields) == count($conditionValues) )
            {
                $query .= " WHERE ".implode(" = ? AND ", $conditionFields);
                $query .= " = ?";
            }

            $stmt = $this->pdoHandle->prepare($query);
            if ( $stmt->execute($values) )
                $result = true;
        }

        return $result;
    } 
}

?>