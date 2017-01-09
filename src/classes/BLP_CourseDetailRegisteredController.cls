Public class BLP_CourseDetailRegisteredController{
    
    public BLP_UtilityController.AdditionalSubscribedCourses subscribedCourseRegistered{get;set;}
    public string courseId;
    public string registerOrWaitlist{get;set;}
    public list<BLP_UtilityController.prePostWork> preWorkList{get;set;}
    public list<BLP_UtilityController.prePostWork> postWorkList{get;set;}
    
    public BLP_CourseDetailRegisteredController(){
        registerOrWaitlist = '';
        courseId = Apexpages.currentPage().getParameters().get('courseId');
        BLP_UtilityController helper = new BLP_UtilityController();
        subscribedCourseRegistered = helper.getSubscribedCourse(courseId);
        preWorkList = helper.prePostWorkList(courseId,'Prework');
        postWorkList = helper.prePostWorkList(courseId,'Postwork');
    }
    
    public void updatePreWork(){
        if(preWorkList != null && preWorkList.size() > 0){
            list<BLP_Prework_Postwork__c> workListToUpdate = new list<BLP_Prework_Postwork__c >();
            for(BLP_UtilityController.prePostWork work : preWorkList){
                BLP_Prework_Postwork__c prePostTemp = new BLP_Prework_Postwork__c();
                prePostTemp.id = work.id;
                
                if(work.completed){
                    prePostTemp.BLP_Status__c = 'Complete';
                    prePostTemp.BLP_Completion_Date__c = System.today();
                }
                else{
                    prePostTemp.BLP_Status__c = 'Not Complete';
                    prePostTemp.BLP_Completion_Date__c = null;
                }
                workListToUpdate.add(prePostTemp);
            }
            if(workListToUpdate != null && workListToUpdate.size() > 0){
                update workListToUpdate;
            }
        }     
    }
    
    public void updateePostWork(){
        if(postWorkList != null && postWorkList.size() > 0){
            list<BLP_Prework_Postwork__c> workListToUpdate = new list<BLP_Prework_Postwork__c >();
            for(BLP_UtilityController.prePostWork work : postWorkList){
                BLP_Prework_Postwork__c prePostTemp = new BLP_Prework_Postwork__c();
                prePostTemp.id = work.id;
                
                if(work.completed){
                    prePostTemp.BLP_Status__c = 'Complete';
                    prePostTemp.BLP_Completion_Date__c = System.today();
                }
                else{
                    prePostTemp.BLP_Status__c = 'Not Complete';
                    prePostTemp.BLP_Completion_Date__c = null;
                }
                workListToUpdate.add(prePostTemp);
            }
            if(workListToUpdate != null && workListToUpdate.size() > 0){
                update workListToUpdate;
            }
        }    
    }
    
    public pagereference DeregisterUser(){
        if(courseId != null){
            list<BLP_User_To_Course__c> ustList = [select id, name, BLP_Course__c, BLP_Training_Dates__c from BLP_User_To_Course__c where BLP_User__c =: UserInfo.getUserId() AND BLP_Course__c =: courseId order by lastModifiedDate desc limit 1];
            if(ustList != null && ustList.size() > 0){
                if(ustList[0].BLP_Training_Dates__c != null){
                    if(registerOrWaitlist == 'Registered'){
                        ustList[0].BLP_Status__c = 'Unregistered';
                        list<BLP_Training_Dates__c> trainingDatesList = [select id, name, BLP_Number_of_Attendees_Registered__c, BLP_Course__c from BLP_Training_Dates__c where id =: ustList[0].BLP_Training_Dates__c];
                        if(trainingDatesList != null && trainingDatesList.size() > 0){
                            if(trainingDatesList[0].BLP_Number_of_Attendees_Registered__c != null){
                                trainingDatesList[0].BLP_Number_of_Attendees_Registered__c = trainingDatesList[0].BLP_Number_of_Attendees_Registered__c - 1;
                            }
                            update trainingDatesList;
                            if(trainingDatesList[0].BLP_Course__c != null){
                                list<BLP_Course__c> courseList = [select id, name,(select id, name, BLP_User__c from User_To_Course__r where BLP_status__c = 'Waitlisted') from BLP_Course__c where id =: trainingDatesList[0].BLP_Course__c];
                                List<Messaging.SingleEmailMessage> msgList= new List<Messaging.SingleEmailMessage>();
                                for(BLP_Course__c cour : courseList){
                                    for(BLP_User_To_Course__c user : cour.User_To_Course__r){
                                        if(user.BLP_User__c != null){
                                            list<EmailTemplate> template = [select id from EmailTemplate where DeveloperName='BLP_Waitlist_Available'];
                                            if(template != null && template.size() > 0){
                                                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                                                msg.setTemplateId(template[0].id);
                                                msg.setTargetObjectId(user.BLP_User__c);
                                                msg.setSaveAsActivity(false);
                                                msgList.add(msg);
                                            }
                                        }
                                    }
                                }
                                if(msgList != null && msgList.size() > 0){
                                    Messaging.sendEmail(msgList);
                                }
                            }
                        }
                    }
                    else if(registerOrWaitlist == 'Waitlisted'){
                        ustList[0].BLP_Status__c = 'Removed Waitlisted';
                    }
                    update ustList;
                }
                
                PageReference pg = page.BLP_MyTraining;
                pg.setRedirect(true);
                return pg;
            } 
        }
        return null;
    }
}