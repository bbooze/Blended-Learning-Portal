Public With Sharing Class BLP_MyTrainingComponentController{
    
    Public Map<String, UserToCourseWrapper> courseToUserToCourseMap {get;set;}
    Public List<TrainingPathWrapper> TrainingPathWrapperList {get;set;}
    Public List<BLP_UtilityController.AdditionalSubscribedCourses> AddidtionalCoursesList {get;set;}
    public string selectedCourseId{get;set;}
    
    Public BLP_MyTrainingComponentController() {
        selectedCourseId = '';
        BLP_UtilityController helper = new BLP_UtilityController();
        AddidtionalCoursesList = helper.getListOfSubscribedCourse();
        TrainingPathWrapperList = new List<TrainingPathWrapper>();
        courseToUserToCourseMap = new Map<String, UserToCourseWrapper>();
        getCurrentUserTrainingPath();
    }
    
    Public void getCurrentUserTrainingPath() {
      Id currentUserId = UserInfo.getUserId();
      Set<Id> courseIdSet = new Set<Id>();
      Map<String, List<String>> trainingPathToCoursesListMap = new Map<String, List<String>>();
      Map<Id, BLP_Training_Path__c> myTrainingPathMap = new Map<Id, BLP_Training_Path__c>([SELECT Id, Name, BLP_Description__c, (SELECT Id, BLP_Course__c 
                                                                            FROM Course_To_Training_Paths__r) 
                                                          FROM BLP_Training_Path__c 
                                                          WHERE BLP_User__c = :currentUserId]);
      
      if (myTrainingPathMap.size() > 0) {
        for (BLP_Training_Path__c trainPath : myTrainingPathMap.values()) {
          for (BLP_Course_To_Training_Path__c courseToTrain : trainPath.Course_To_Training_Paths__r) {
            courseIdSet.add(courseToTrain.BLP_Course__c);
            if (!trainingPathToCoursesListMap.containsKey(trainPath.Id)) {
              trainingPathToCoursesListMap.put(trainPath.Id, new List<String>());
            }
            trainingPathToCoursesListMap.get(trainPath.Id).add(courseToTrain.BLP_Course__c);
          }
        }
        system.debug('trainingPathToCoursesListMapp '+trainingPathToCoursesListMap);
        Map<Id, BLP_Course__c> myCoursesMap = new Map<Id, BLP_Course__c>([SELECT Id, Name, BLP_Mandatory__c, BLP_Course_Name__c, BLP_Course_Format__c, BLP_Training_Categories__c,BLP_Status__c,
                                                                                (SELECT ID, BLP_User__c, BLP_Status__c, BLP_Date_of_Completion__c, 
                                                                                        BLP_Training_Dates__r.BLP_Training_Date_Time__c
                                                                                 FROM User_To_Course__r WHERE BLP_User__c = :currentUserId) 
                                                                          FROM BLP_Course__c 
                                                                          WHERE Id IN :courseIdSet]);
        system.debug('myCoursesMapp '+myCoursesMap); 
        
        for (BLP_Course__c course : myCoursesMap.values()) {
            for (BLP_User_To_Course__c userToCourse : course.User_To_Course__r) {
              courseToUserToCourseMap.put(course.Id, new UserToCourseWrapper(userToCourse));
            }
            if(course.User_To_Course__r.size() <= 0) {
              courseToUserToCourseMap.put(course.Id, new UserToCourseWrapper(null));
            }
        }
        system.debug('courseToUserToCourseMapp '+courseToUserToCourseMap); 
        
        for (String trainPathId : trainingPathToCoursesListMap.keySet()) {
          Integer totalCourseCount = 0;
          Integer mandatoryCourseCount = 0;
          Integer completedCourseCount = 0;
          Map<String, List<BLP_Course__c>> courseCategoryToCourseListMap = new Map<String, List<BLP_Course__c>>();
          for(String courseId : trainingPathToCoursesListMap.get(trainPathId)){
              totalCourseCount++;
              if (myCoursesMap.get(courseId).BLP_Mandatory__c == true) {
                mandatoryCourseCount++;
              }
              if (courseToUserToCourseMap.get(courseId).status == 'Completed') {
                completedCourseCount++;
              }
              String courseCategory = myCoursesMap.get(courseId).BLP_Training_Categories__c;
              if (!courseCategoryToCourseListMap.containsKey(courseCategory)) {
                courseCategoryToCourseListMap.put(courseCategory, new List<BLP_Course__c>());
              }
              courseCategoryToCourseListMap.get(courseCategory).add(myCoursesMap.get(courseId));
          }
          TrainingPathWrapperList.add(new TrainingPathWrapper(myTrainingPathMap.get(trainPathId), totalCourseCount, mandatoryCourseCount, 
                                                              completedCourseCount, courseCategoryToCourseListMap));
        }
        system.debug('TrainingPathWrapperListt '+TrainingPathWrapperList);
      } else {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.BLP_No_Training_Path);
        ApexPages.addMessage(myMsg);
      }
    }
    
    public pagereference redirectUser(){
        if(selectedCourseId != null && selectedCourseId != ''){
            BLP_UtilityController helper = new BLP_UtilityController();
            return helper.redirectUserCommon(selectedCourseId);
        }
        return null;
    }
    
    Public Class TrainingPathWrapper {
      Public BLP_Training_Path__c trainPath {get;set;}
      Public Decimal totalCourseCount {get;set;}
      Public Integer mandatoryCourseCount {get;set;}
      Public Decimal completedCourseCount {get;set;}
      Public Decimal completedCoursePercent {get;set;}
      Public Map<String, List<BLP_Course__c>> courseCategoryToCourseListMap {get;set;}
      Public TrainingPathWrapper(BLP_Training_Path__c trainPath, Decimal totalCourseCount, Integer mandatoryCourseCount, 
                                 Decimal completedCourseCount, Map<String, List<BLP_Course__c>> courseCategoryToCourseListMap) {
        this.trainPath = trainPath;
        this.totalCourseCount = totalCourseCount;
        this.mandatoryCourseCount = mandatoryCourseCount;
        this.completedCourseCount = completedCourseCount;
        this.completedCoursePercent = completedCourseCount/totalCourseCount;
        this.courseCategoryToCourseListMap = courseCategoryToCourseListMap;
      }
  }
      
      Public Class UserToCourseWrapper {
          Public BLP_User_To_Course__c userToCourse {get;set;}
          Public String status {get;set;}
          Public DateTime trainingDate {get;set;}
          
          Public UserToCourseWrapper(BLP_User_To_Course__c userToCourse) {
            this.userToCourse = userToCourse;
            if(userToCourse != null) {
              this.status = Label.BLP_In_Progress;
              this.trainingDate = userToCourse.BLP_Training_Dates__r.BLP_Training_Date_Time__c;
              if (userToCourse.BLP_Date_of_Completion__c != null) {
                  this.status = Label.BLP_Completed;
              }
            } else {
              this.status = Label.BLP_Not_Registered;
            }
          }
    }
    
}