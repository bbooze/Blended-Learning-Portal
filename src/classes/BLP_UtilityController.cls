Public class BLP_UtilityController{
    
    public AdditionalSubscribedCourses getSubscribedCourse(string courseId){
        AdditionalSubscribedCourses tempCourses = new AdditionalSubscribedCourses();
        map<string,string> trainingPathsMap = new map<string,string>();
        map<string,string> PreRequisiteMap = new map<string,string>();
        map<string,string> PrePostWorkMapMap = new map<string,string>();
        list<TraingDatesWrapper> trainingDates = new list<TraingDatesWrapper>();
        string registeredUserTrainingId = '';
         
        if(courseId != null && courseId != ''){
            list<BLP_Course__c> CourseList = initQuery(courseId, '1');
            if(CourseList != null && CourseList.size() > 0){
                BLP_Course__c newCourse = CourseList[0];
                if(newCourse.BLP_Course_Name__c != null){
                    tempCourses.CourseId = newCourse.Id;
                    tempCourses.CourseName = newCourse.BLP_Course_Name__c;
                    tempCourses.CourseType = newCourse.BLP_Course_Format__c;
                    tempCourses.CourseStatus = newCourse.BLP_Status__c;
                    tempCourses.CourseMandatory = newCourse.BLP_Mandatory__c;
                    tempCourses.CourseDescription = newCourse.BLP_Description__c;
                    tempCourses.courseExpertName = newCourse.BLP_Course_Expert__c;
                    tempCourses.courseExpertEmail = newCourse.BLP_Course_Expert_Email__c;
                    tempCourses.techExpertName = newCourse.BLP_Tech_Support__c;
                    tempCourses.techExpertEmail = newCourse.BLP_Tech_Support_Email__c;
                    if(newCourse.BLP_Prerequiste_Course__c != null){
                        PreRequisiteMap.put(newCourse.BLP_Prerequiste_Course__r.BLP_Course_Name__c, '<a target="_blank" style="cursor:pointer;" onclick="redirectUserAF(\''+newCourse.BLP_Prerequiste_Course__c+'\');return false;">'+newCourse.BLP_Prerequiste_Course__r.BLP_Course_Name__c+'</a>');
                    }
                    
                    if(newCourse.Training_Dates__r != null && newCourse.Training_Dates__r.size() > 0){
                        tempCourses.CourseTrainingDate = newCourse.Training_Dates__r[0].BLP_Training_Date_Time__c;
                        tempCourses.CourseLocation = newCourse.Training_Dates__r[0].BLP_Course_Location__c ;
                    }
                    
                    for(BLP_User_To_Course__c utc : newCourse.User_To_Course__r){
                        if(utc.BLP_user__c == userInfo.getUserId()){
                            tempCourses.userToCourseId = utc.id;
                            if(!(utc.BLP_Status__c.equalsIgnoreCase('Unregistered') || utc.BLP_Status__c.equalsIgnoreCase('Removed Waitlisted'))){
                                registeredUserTrainingId = utc.BLP_Training_Dates__c;
                                tempCourses.userToCourceRegisterOrWait = utc.BLP_Status__c;
                            }
                        }
                    }
                    
                    for(BLP_Training_Dates__c dates : newCourse.Training_Dates__r){
                        if(dates.BLP_Training_Date_Time__c != null){
                            TraingDatesWrapper trainDate = new TraingDatesWrapper();
                            trainDate.trainingId = dates.id;
                            trainDate.trainingDate = dateFormat(dates.BLP_Training_Date_Time__c);
                            trainDate.trainingTime = timeFormat(dates.BLP_Training_Date_Time__c);
                            trainDate.trainingLocation = dates.BLP_Course_Location__c;
                            if(dates.BLP_Max_Capacity__c != null){
                                if(dates.BLP_Number_of_Attendees_Registered__c != null){
                                    trainDate.maxCapacity = string.valueOf(dates.BLP_Max_Capacity__c - dates.BLP_Number_of_Attendees_Registered__c);
                                }
                                else{
                                    trainDate.maxCapacity = string.valueOf(dates.BLP_Max_Capacity__c);
                                }
                            }
                            else{
                                trainDate.maxCapacity = '0';
                            }
                            
                            if(registeredUserTrainingId != null && registeredUserTrainingId != '' && registeredUserTrainingId == dates.id){
                                trainDate.registeredTrainingId = dates.id;
                                tempCourses.currentlyRegisteredDate = trainDate.trainingDate + ' ' + trainDate.trainingTime + ' ' + trainDate.trainingLocation;
                            }
                            trainingDates.add(trainDate);
                        }
                    }
                    
                    for(BLP_Course_To_Training_Path__c paths : newCourse.Course_To_Training_Paths__r){
                        if(paths.BLP_Training_Path__c != null){
                            trainingPathsMap.put(paths.BLP_Training_Path__r.name,'#');
                        }
                    }
                    /*
                    for(BLP_Pre_Post_Work__c PrePostWork : newCourse.Pre_Post_Work__r){
                        PrePostWorkMapMap.put(PrePostWork.name, PrePostWork.BLP_Link_to_Content__c);
                    }
                    */
                    tempCourses.trainingDatesWrapList = trainingDates;
                    tempCourses.PreRequisiteMap = PreRequisiteMap;
                    tempCourses.trainingPathsMap = trainingPathsMap;
                    if(PreRequisiteMap != null && PreRequisiteMap.size() > 0){
                        tempCourses.prerequisiteSize = true;
                    }
                    else{
                        tempCourses.prerequisiteSize = false;
                    }
                    if(trainingPathsMap != null && trainingPathsMap.size() > 0){
                        tempCourses.trainingPathSize = true;
                    }
                    else{
                        tempCourses.trainingPathSize = false;
                    }
                }
            }
        }
        return tempCourses;
    }
    
    public list<AdditionalSubscribedCourses> getListOfSubscribedCourse(){
        list<AdditionalSubscribedCourses> lstAdditionalSubscribedCourses = new list<AdditionalSubscribedCourses>();
        //list<Course__c> lstOfRegisteredCourses = new list<Course__c>();
        map<Id,BLP_User_To_Course__c> mapCourseUserToCourse = new map<Id,BLP_User_To_Course__c>();
        set<Id> usrtrainingPath = new set<Id>();
        AdditionalSubscribedCourses tempCourses;
        set<String> statusSetForQuery = new set<String>();
        statusSetForQuery.add('Registered');
        statusSetForQuery.add('Registered Without Date');
        statusSetForQuery.add('Waitlisted');
        for(BLP_User_To_Course__c userToCourse : [  select id, name, BLP_Course__c, BLP_Training_Dates__c, BLP_Training_Dates__r.BLP_Training_Date_Time__c, 
                                                        BLP_Training_Dates__r.BLP_Course_Location__c, BLP_Status__c, BLP_Course__r.BLP_Course_Name__c,
                                                        BLP_Course__r.BLP_Course_Format__c, BLP_Course__r.BLP_Status__c, BLP_Course__r.BLP_Mandatory__c,
                                                        BLP_Course__r.BLP_Description__c
                                                    from BLP_User_To_Course__c 
                                                    where BLP_User__c =: UserInfo.getUserId()
                                                    and BLP_Status__c in : statusSetForQuery]){
            //lstOfRegisteredCourses.add(userToCourse.Course__c);
            if(userToCourse.BLP_Course__r != null && 
                    userToCourse.BLP_Course__r.BLP_Status__c != null &&  
                    userToCourse.BLP_Course__r.BLP_Status__c.equals('Active')){
                mapCourseUserToCourse.put(userToCourse.BLP_Course__c, userToCourse);
            }        
        }
        for(BLP_Training_Path__c trainingPath : [Select id from BLP_Training_Path__c where BLP_User__c =: UserInfo.getUserId()]){
            usrtrainingPath.add(trainingPath.Id);
        }
        System.debug('usrtrainingPath-------->'+usrtrainingPath);
        for(BLP_Course_To_Training_Path__c courseToTrainingPath : [Select id, BLP_Course__c from BLP_Course_To_Training_Path__c
                                                                    where BLP_Course__c in : mapCourseUserToCourse.keySet()
                                                                    And BLP_Training_Path__c in : usrtrainingPath]){
            mapCourseUserToCourse.remove(courseToTrainingPath.BLP_Course__c);
        }
        for(BLP_User_To_Course__c userToCourse : mapCourseUserToCourse.values()){
            tempCourses = new AdditionalSubscribedCourses();
            tempCourses.CourseId = userToCourse.BLP_Course__r.Id;
            tempCourses.CourseName = userToCourse.BLP_Course__r.BLP_Course_Name__c;
            tempCourses.CourseType = userToCourse.BLP_Course__r.BLP_Course_Format__c;
            tempCourses.CourseStatus = userToCourse.BLP_Course__r.BLP_Status__c;
            tempCourses.CourseMandatory = userToCourse.BLP_Course__r.BLP_Mandatory__c;
            tempCourses.CourseDescription = userToCourse.BLP_Course__r.BLP_Description__c;
            tempCourses.CourseTrainingDate = userToCourse.BLP_Training_Dates__r.BLP_Training_Date_Time__c;
            tempCourses.CourseLocation = userToCourse.BLP_Training_Dates__r.BLP_Course_Location__c;
            tempCourses.userToCourseStatus = userToCourse.BLP_Status__c;
            System.debug('tempCourses-------->'+tempCourses);
            lstAdditionalSubscribedCourses.add(tempCourses);
        }
        return lstAdditionalSubscribedCourses;
    }
    
    public string dateFormat(dateTime trainingDate){
        string stringDate = '';
        if(trainingDate != null){
            stringDate += trainingDate.Month() + '/' + trainingDate.day() + '/' + trainingDate.year();
        }
        return stringDate;
    }
    
    public string timeFormat(dateTime trainingDate){
        string stringTime = '';
        if(trainingDate != null){
            stringTime += trainingDate.format('HH:mm a');
        }
        //stringTime = '4:00 PM';
        return stringTime;
    }
    
    public list<BLP_Course__c> initQuery(string courseId, string limitQuery){
        string query = 'select id, name, BLP_Status__c, BLP_Course_Name__c, BLP_Course_Format__c, BLP_Description__c, BLP_Affiliate__c, BLP_Mandatory__c, BLP_Prerequiste_Course__r.BLP_Course_Name__c, '
                       + 'BLP_Course_Expert__c, BLP_Course_Expert_Email__c, BLP_Tech_Support__c, BLP_Tech_Support_Email__c, BLP_Prerequiste_Course__c, ' 
                       + '(select id, name, BLP_Training_Date_Time__c, BLP_Course_Location__c, BLP_Max_Capacity__c, BLP_Number_of_Attendees_Registered__c from Training_Dates__r), ' 
                       + '(select id, name, BLP_Course__c, BLP_Training_Path__c, BLP_Training_Path__r.name from Course_To_Training_Paths__r), ' 
                       + '(select id, name, BLP_Link_to_Content__c from Pre_Post_Work__r),(select id, name, BLP_user__c, BLP_Training_Dates__c,BLP_Status__c from User_To_Course__r) from BLP_Course__c where BLP_Status__c = \'Active\' ';
        if(courseId != null && courseId != ''){
            query += 'AND id = \'' + courseId + '\' ';
        }
        if(limitQuery != null && limitQuery != ''){
            query += 'limit ' + limitQuery + '';
        }
        system.debug('query----------'+query);
        list<BLP_Course__c> CourseList = database.query(query);
        system.debug('CourseList----------'+CourseList);
        return CourseList;
    }
    
    public pagereference redirectUserCommon(string courseId){
        list<BLP_User_To_Course__c> utc = [select id, name, BLP_Status__c, BLP_Course__c , BLP_Course__r.BLP_Course_Format__c from BLP_User_To_Course__c where BLP_user__c =: userInfo.getUserId() AND BLP_Course__c =: courseId limit 1];
        PageReference pg;
        if(utc != null && utc.size() > 0){
            if(utc[0].BLP_Course__r.BLP_Course_Format__c == 'Face to Face' || utc[0].BLP_Course__r.BLP_Course_Format__c == 'Virtual Classroom' ){
                if(utc[0].BLP_Status__c == 'Registered' || utc[0].BLP_Status__c == 'Registered Without Date'){
                    pg = page.BLP_CourseDetailRegistered;
                } else{
                    pg = page.BLP_CourseDetailUnregistered;
                }
            } else{
                pg = page.BLP_CourseDetailLink;
            }
            pg.getParameters().put('courseId', courseId);
            pg.setRedirect(true);
            return pg;
        } else {
            pg = page.BLP_CourseDetailUnregistered;
            pg.getParameters().put('courseId', courseId);
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }
    
    Public Static BLP_Course__c checkPrerequisiteCourses(String courseId) {
      BLP_Course__c courseToRegister = [SELECT Id, Name, BLP_Course_Name__c, BLP_Prerequiste_Course__c
                                        FROM BLP_Course__c 
                                        WHERE Id = :courseId 
                                        LIMIT 1]; 
      if(courseToRegister.BLP_Prerequiste_Course__c != null) {
        System.debug('PreRequisite Course Found - '+courseToRegister.BLP_Prerequiste_Course__c);
        BLP_Course__c preRequisiteCourse = [SELECT Id, Name, BLP_Course_Name__c,
                                                   (SELECT Id, Name, BLP_Date_of_Completion__c
                                                    FROM User_To_Course__r
                                                    WHERE BLP_User__c = :UserInfo.getUserId()) 
                                            FROM BLP_Course__c 
                                            WHERE Id = :courseToRegister.BLP_Prerequiste_Course__c 
                                            LIMIT 1];
        if(preRequisiteCourse.User_To_Course__r.size() > 0) {                                    
          for (BLP_User_To_Course__c utc : preRequisiteCourse.User_To_Course__r) {
            if (utc.BLP_Date_of_Completion__c == null) {
              return preRequisiteCourse;
            }
          }
        } else {
          return preRequisiteCourse;
        }
        return null;
      } else {
        return null;
      }
    }
    
    public list<prePostWork> prePostWorkList(string courseId, string type){
        list<prePostWork> tempprePostList = new list<prePostWork>();
        if(courseId != null && courseId != ''){
            list<BLP_User_To_Course__c> utcList = new list<BLP_User_To_Course__c>();
            if(type != null && type != ''){
                utcList = [select id, name,(select id, name, BLP_Status__c, BLP_Link_to_Content__c, BLP_Type__c from Prework_Postwork__r where BLP_Type__c =: type) from BLP_User_To_Course__c where blp_course__c =: courseId AND blp_user__c =: userinfo.getUserId()];
            }
            else{
                utcList = [select id, name,(select id, name, BLP_Status__c, BLP_Link_to_Content__c, BLP_Type__c from Prework_Postwork__r) from BLP_User_To_Course__c where blp_course__c =: courseId AND blp_user__c =: userinfo.getUserId()];
            }
            if(utcList != null && utcList.size() > 0){
                for(BLP_Prework_Postwork__c prePost : utcList[0].Prework_Postwork__r){
                    tempprePostList.add(new prePostWork(prePost.name,prePost.BLP_Link_to_Content__c,prePost.BLP_Status__c,prePost.id));
                }
            }
        }
        return tempprePostList;
    }
    
    Public Class AdditionalSubscribedCourses{
        
        Public string CourseId{get;set;}
        Public string CourseName{get;set;}
        Public string CourseType{get;set;}
        public string CourseStatus{get;set;}
        Public dateTime CourseTrainingDate{get;set;}
        Public string CourseLocation{get;set;}
        Public boolean CourseMandatory{get;set;}
        Public string CourseDescription{get;set;}
        public map<string,string> trainingPathsMap{get;set;}
        public map<string,string> PreRequisiteMap{get;set;}
        public map<string,string> PrePostWorkMapMap{get;set;}
        public string courseExpertName{get;set;}
        public string courseExpertEmail{get;set;}
        public string techExpertName{get;set;}
        public string techExpertEmail{get;set;}
        public string userToCourseId{get;set;}
        public string currentlyRegisteredDate{get;set;}
        public string userToCourceRegisterOrWait{get;set;}
        public string userToCourseStatus{get;set;}
        public list<TraingDatesWrapper> trainingDatesWrapList{get;set;}
        Public boolean trainingPathSize{get;set;}
        Public boolean prerequisiteSize{get;set;}
        
    } 
    
    Public class TraingDatesWrapper{
        Public string trainingId{get;set;}
        public string registeredTrainingId{get;set;}
        public string registereduserToCourseId{get;set;}
        Public string trainingDate{get;set;}
        Public string trainingTime{get;set;}
        Public string trainingLocation{get;set;}
        Public string maxCapacity{get;set;}
    }
    
    public class prePostWork{
        public string id{get;set;}
        public string Name{get;set;}
        public string url{get;set;}
        public boolean completed{get;set;}
        
        public prePostWork(string Name, string url, string completedOrNot, string id){
            this.id = id;
            this.name = name;
            this.url = url;
            if(url != null && url != ''){
                this.url = url;
            }
            else{
                this.url = '#';            
            }
            if(completedOrNot == 'Complete'){
                this.completed = true;
            }
            else{
                this.completed = false;            
            }
        }
    }
   
}