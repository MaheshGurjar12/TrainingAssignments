global class ScheduleBatchOnStudents implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    
    List<Student__c> studentList = new List<Student__c>();
    
    Integer countMarkedStudents =0;
    
    /**
description: this method  query the records from the database
params : Database.BatchableContext contex
returns : Returns the records fetched by the query
**/
    global Database.QueryLocator start(Database.BatchableContext context){
        
        return Database.getQueryLocator([SELECT Mark_For_Delete__c, 
                                         CreatedById, Is_Registration_Completed__c
                                         FROM Student__c WHERE Is_Registration_Completed__c = false 
                                        ]);
    }
    
    /**
description: this method updates the  records recieved from  start() method
params : Database.BatchableContext contex, List<Student__c> studentsToUpdate
return : void
**/
    global void execute(Database.BatchableContext context, List<Student__c> studentsToUpdate){
        for(Student__c student : studentsToUpdate){
            
            student.Mark_For_Delete__c = 'Yes';
            this.studentList.add(student);
        }
        update studentsToUpdate;
        
    }
    
    /**
description: this method  calls the sendemail() method
params : Database.BatchableContext contex
return : void
**/
    global void finish(Database.BatchableContext context){
        sendEmail();
    }
    
    /**
description: This method will send an email to the creator of student records
params : None
return : void
**/
    private void sendEmail() {
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        List<String> allEmails = new List<String>();
        
        Set<Id> createdByIds = new Set<Id>();
        for (Student__c student : studentList) {
            createdByIds.add(student.CreatedById);
        }
        Map<Id, Integer> countStudents = new Map<Id, Integer>();
        for(Student__c student : [SELECT CreatedById FROM Student__c WHERE Id IN :studentList]){
            if(countStudents.containsKey(student.CreatedById))
            {
                this.countMarkedStudents++;
                countStudents.put(student.CreatedById, this.countMarkedStudents);
            }
            else{
                this.countMarkedStudents = 0;
                this.countMarkedStudents++;
                countStudents.put(student.CreatedById, this.countMarkedStudents);
            }
        }        
        Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :createdByIds]);
 
        for (Id creatorId : countStudents.keySet()) {
            Integer count = countStudents.get(creatorId);
            if (count>0) { 
                User creator = usersMap.get(creatorId);  
                if (creator != null && creator.Email != null) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{creator.Email});
                    mail.setSubject('Batch Job Completed');
                    mail.setPlainTextBody('Hey, the batch Job Completed. Number of students marked for deletion: '+count);
                    mails.add(mail);
                }
            }
        }
        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
        }
        else {
            System.debug('No email addresses found to send the email to.');
        }
    }
    
    /**
description: This method we schedule the batch class
params : SchedulableContext context
return : void
**/
    global void execute(SchedulableContext context){
        ScheduleBatchOnStudents scheduleBatch = new ScheduleBatchOnStudents();
        Database.executeBatch(scheduleBatch);
    }
}