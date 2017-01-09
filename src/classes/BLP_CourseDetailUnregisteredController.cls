Public class BLP_CourseDetailUnregisteredController{
    
    public BLP_UtilityController.AdditionalSubscribedCourses subscribedCourseUnregistered{get;set;}
    
    public string selectedDate{get;set;}
    public string courseId;
    public string registerOrWaitlist{get;set;}
    public string canRegisterAlso{get;set;}
    Public String prerequisiteCourseId {get;set;}
    Public String prerequisiteCourseLink {get;set;}
    
    Public BLP_CourseDetailUnregisteredController(){
        selectedDate = '';
        registerOrWaitlist = '';
        canRegisterAlso = 'false';
        courseId = Apexpages.currentPage().getParameters().get('courseId');
        BLP_UtilityController helper = new BLP_UtilityController();
        subscribedCourseUnregistered = helper.getSubscribedCourse(courseId);
    }
    
    public pagereference registerUser(){
        if(courseId != null){
            List<BLP_Course__c> prerequisiteCourseList = new List<BLP_Course__c>();
            prerequisiteCourseList.add(BLP_UtilityController.checkPrerequisiteCourses(courseId));
            System.debug('prerequisiteCourseListt '+prerequisiteCourseList);
            if (prerequisiteCourseList.size() > 0 && prerequisiteCourseList[0] != null) {
                prerequisiteCourseLink = '<a target="_blank" style="cursor:pointer;"  onclick="redirectUserAF(\''+prerequisiteCourseList[0].Id+'\');">'+prerequisiteCourseList[0].BLP_Course_Name__c+'</a>';
                System.debug('prerequisiteCourseLinkk '+prerequisiteCourseLink);
                return null;
            } else {
                BLP_User_To_Course__c userToCourse = new BLP_User_To_Course__c();
                if(subscribedCourseUnregistered.userToCourseId != null && subscribedCourseUnregistered.userToCourseId != ''){
                    userToCourse.id = subscribedCourseUnregistered.userToCourseId;
                }
                else{
                    userToCourse.BLP_Course__c = courseId;
                }
                userToCourse.BLP_User__c = userInfo.getUserId();
                userToCourse.BLP_Email__c = userInfo.getUserEmail();
                if(selectedDate != null && selectedDate != ''){
                    userToCourse.BLP_Training_Dates__c = selectedDate;
                    if(registerOrWaitlist == 'Register'){
                        userToCourse.BLP_Status__c = 'Registered';
                        list<BLP_Training_Dates__c> trainingDatesList = [select id, name, BLP_Number_of_Attendees_Registered__c from BLP_Training_Dates__c where id =: selectedDate];
                        if(trainingDatesList != null && trainingDatesList.size() > 0){
                            if(trainingDatesList[0].BLP_Number_of_Attendees_Registered__c == null){
                                trainingDatesList[0].BLP_Number_of_Attendees_Registered__c = 1;
                            }
                            else{
                                trainingDatesList[0].BLP_Number_of_Attendees_Registered__c = trainingDatesList[0].BLP_Number_of_Attendees_Registered__c + 1;
                            }
                            update trainingDatesList;
                        }
                    }
                    else if(registerOrWaitlist == 'Waitlisted'){
                        userToCourse.BLP_Status__c = 'Waitlisted';
                    }
                }
                else{
                    userToCourse.BLP_Status__c = 'Registered Without Date';
                }
               
                upsert userToCourse;
                
                PageReference pg = page.BLP_CourseDetailRegistered;
                pg.getParameters().put('courseId', courseId);
                pg.setRedirect(true);
                return pg;
            }    
        }
        return null;
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
                    if(registerOrWaitlist == 'Waitlisted'){
                        ustList[0].BLP_Status__c = 'Removed Waitlisted';
                        if(canRegisterAlso == 'true'){
                            PageReference pg = page.BLP_MyTraining;
                            pg.setRedirect(true);
                            return pg;
                        }
                    }
                }
            } 
        }
        return null;
    }
    
    Public PageReference redirectUser() {
        System.debug('prerequisiteCourseIdd '+prerequisiteCourseId);
        if(!String.isBlank(prerequisiteCourseId)){
            BLP_UtilityController helper = new BLP_UtilityController();
            return helper.redirectUserCommon(prerequisiteCourseId);
        }
        return null;
    }
}