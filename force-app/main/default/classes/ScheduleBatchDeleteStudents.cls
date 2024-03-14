global class ScheduleBatchDeleteStudents implements Database.Batchable<sObject>, Schedulable{
    
    /**
description: this method  query the records from the database
params : Database.BatchableContext context
returns : Returns the records fetched by the query
**/
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator([SELECT Id FROM Student__c WHERE Mark_For_Delete__c='Yes']);
    }
    
    /**
description: This method  deletes the student records that were marked to delete
params : Database.BatchableContext context, List<Student__c> studentList
return : void
**/
    global void execute(Database.BatchableContext context, List<Student__c> studentList){
        
        delete studentList;
        
    }
    
    /**
description: This method used for post processing
params : Database.BatchableContext context
return : void
**/
    global void finish(Database.BatchableContext context){
        
    }
    
    /**
description: This method we schedule the batch class
params : SchedulableContext context
return : void
**/
    global void execute(SchedulableContext sc){
        ScheduleBatchOnStudents scheduleBatch = new ScheduleBatchOnStudents();
        Database.executeBatch(scheduleBatch);
    }
}