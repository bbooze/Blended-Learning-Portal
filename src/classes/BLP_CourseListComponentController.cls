Public Class BLP_CourseListComponentController{
     
    public string inputSearchText{get;set;}
    public string TraingTypeSelected{get;set;}
    public string TraingPathSelected{get;set;}
    public list<selectOption> trainingTypeList{get;set;}
    public list<selectOption> trainingPathList{get;set;}
    public string sortingSelected{get;set;}
    public static string Sort_Dir{get;set;}
    public map<string,map<string,list<groupCourses>>> trainingTypeGroupingMap{get;set;}
    public boolean showCheckBox{get;set;}
    public boolean checkBoxVal{get;set;}
    public string selectedCourseId{get;set;}
    
    Public BLP_CourseListComponentController(){
        selectedCourseId = '';
        sortingSelected = 'A-Z';
        Sort_Dir = 'A-Z';
        showCheckBox = false;
        checkBoxVal = false;
        trainingTypeList = getTraingTypeSelectList();
        trainingPathList = getTraingPathSelectList();
        trainingTypeGroupingMap = getCoursesByGrouping('','','');
    }
    
    public List<SelectOption> getTraingTypeSelectList(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = BLP_Course__c.BLP_Training_Categories__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Select Category'));
        for(Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<SelectOption> getTraingPathSelectList(){
        List<SelectOption> options = new List<SelectOption>();
        list<BLP_Training_Path__c> pathList = [select id, name from BLP_Training_Path__c limit 1000];
        options.add(new SelectOption('', 'Select Training Path'));
        for(BLP_Training_Path__c path : pathList ){
            options.add(new SelectOption(path.id, path.name));
        }       
        return options;
    }
    
    public map<string,map<string,list<groupCourses>>> getCoursesByGrouping(string searchString, string trainingType, string trainingPath){
        Map<String, BLP_Language_Setting__c> languagesMap = BLP_Language_Setting__c.getAll();
        string userLanguage = UserInfo.getLanguage();
        if(languagesMap != null && languagesMap.size() > 0 && userLanguage != null && userLanguage != ''){
            userLanguage = languagesMap.get(UserInfo.getLanguage()).Corresponding_Language__c;
        }
        
        list<profile> profileList = [select id, name from profile where id =: userInfo.getProfileId()];
        if(profileList != null && profileList.size() > 0){
            if(profileList[0].name == Label.BLP_Profile_Name_For_Course_List){
                showCheckBox = true;
            }
        }
        
        if(!showCheckBox){
            checkBoxVal = true;
        }
        
        map<string,map<string,list<groupCourses>>> groupingMap = new map<string,map<string,list<groupCourses>>>();
        String innerQuery = 'select id, name, BLP_Course__c, BLP_Course__r.BLP_Course_Name__c, BLP_Course__r.BLP_Training_Categories__c, '
                           + 'BLP_Course__r.BLP_Mandatory__c, BLP_Course__r.BLP_Course_Format__c, BLP_Course__r.id from Course_To_Training_Paths__r where (BLP_Course__c != null and BLP_Course__r.BLP_Status__c = \'Active\'';
        if(checkBoxVal){
            innerQuery += ' and BLP_Course__r.BLP_Affiliate__c = \'' + userLanguage + '\'';
        }
        
        if(searchString != null && searchString != ''){
            if(searchString.contains('\'')){
                searchString = String.escapeSingleQuotes(searchString);
            }
            innerQuery += ' AND BLP_Course__r.BLP_Course_Name__c like \'%' + searchString + '%\'';
        }
        
        if(showCheckBox){
            innerQuery += ') and (BLP_Course__r.BLP_Availability__c = \'Private\' or BLP_Course__r.BLP_Availability__c = \'Open\')';
           // innerQuery += ' and BLP_Course__r.BLP_Availability__c = \'Open\')';
        }
        else{
            innerQuery += ' and BLP_Course__r.BLP_Availability__c = \'Open\')';
        }
        
        string queryString = 'select id, name, ('+ innerQuery +' )' 
                           + ' from BLP_Training_Path__c where id != null ';
                           
        if(trainingPath != null && trainingPath != '' && trainingPath != 'other'){
            queryString += ' AND id = \'' + trainingPath + '\' ';
        }
        queryString += ' limit 1000'; 
        system.debug(queryString );                  
        list<BLP_Training_Path__c> trainingPathTempList = database.query(queryString);
        
        Set<Id> includedCourses = new Set<Id>();
        Map<Id,DateTime> courseDates = new Map<Id,DateTime>();
        BLP_UtilityController utilitiy = new BLP_UtilityController();
        for(BLP_Training_Dates__c trainingDate : [select id,BLP_Course__c,BLP_Training_Date_Time__c from BLP_Training_Dates__c where BLP_Course__c != null and BLP_Training_Date_Time__c != null]){
            courseDates.put(trainingDate.BLP_Course__c , trainingDate.BLP_Training_Date_Time__c );
        }
        
        for(BLP_Training_Path__c paths : trainingPathTempList){
            map<string,list<groupCourses>> tempInnerMap = new map<string,list<groupCourses>>();
            for(BLP_Course_To_Training_Path__c coursePath : paths.Course_To_Training_Paths__r){
                if(coursePath.BLP_Course__c != null && coursePath.BLP_Course__r.BLP_Training_Categories__c != null && (trainingType == null || trainingType == '' || (trainingType != null && trainingType != '' && trainingType == coursePath.BLP_Course__r.BLP_Training_Categories__c))){
                    includedCourses.add(coursePath.BLP_Course__c);
                    list<groupCourses> tempList = new list<groupCourses>();
                    if(tempInnerMap.containsKey(coursePath.BLP_Course__r.BLP_Training_Categories__c)){
                        tempList = tempInnerMap.get(coursePath.BLP_Course__r.BLP_Training_Categories__c);
                    }
                    String courseDate = null;
                    if(courseDates.containsKey(coursePath.BLP_Course__r.id)){
                        courseDate = utilitiy.dateFormat(courseDates.get(coursePath.BLP_Course__r.id)) +' '+ utilitiy.timeFormat(courseDates.get(coursePath.BLP_Course__r.id));
                    }
                    tempList.add(new groupCourses(coursePath.BLP_Course__r.id,coursePath.BLP_Course__r.BLP_Course_Name__c,coursePath.BLP_Course__r.BLP_Course_Format__c,courseDate ,coursePath.BLP_Course__r.BLP_Mandatory__c));
                    tempList.sort();
                    tempInnerMap.put(coursePath.BLP_Course__r.BLP_Training_Categories__c,tempList);
                }
            }
            if(tempInnerMap.size() > 0 && trainingPath != 'other'){
                groupingMap.put(paths.name,tempInnerMap);
            }
        }
        
        if(trainingPath == null || trainingPath == '' || trainingPath == 'other'){
            map<string,list<groupCourses>> tempInnerMap = new map<string,list<groupCourses>>();
            String otherQuery = 'select id,BLP_Course_Name__c,BLP_Training_Categories__c,BLP_Mandatory__c, BLP_Course_Format__c from BLP_Course__c where (id not in: includedCourses and BLP_Status__c = \'Active\'';
            if(checkBoxVal){
                otherQuery += ' and BLP_Affiliate__c = \'' + userLanguage + '\'';
            }
            if(searchString != null && searchString != ''){
                otherQuery += ' AND BLP_Course_Name__c like \'%' + searchString + '%\'';
            }
            if(showCheckBox){
               otherQuery += ') and (BLP_Availability__c = \'Private\' or BLP_Availability__c = \'Open\')';
                //otherQuery += ' and BLP_Availability__c = \'Open\')';
            }
            else{
                otherQuery += ' and BLP_Availability__c = \'Open\')';
            }
            otherQuery += ' limit 10000';
            System.debug(otherQuery);
            for(BLP_Course__c course : Database.query(otherQuery)){
                if(course.BLP_Training_Categories__c != null && (trainingType == null || trainingType == '' || (trainingType != null && trainingType != '' && trainingType == course.BLP_Training_Categories__c))){
                    
                    list<groupCourses> tempList = new list<groupCourses>();
                    if(tempInnerMap.containsKey(course.BLP_Training_Categories__c)){
                        tempList = tempInnerMap.get(course.BLP_Training_Categories__c);
                    }
                    String courseDate = null;
                    if(courseDates.containsKey(course.id)){
                        courseDate = utilitiy.dateFormat(courseDates.get(course.id)) +' '+ utilitiy.timeFormat(courseDates.get(course.id));
                    }
                    tempList.add(new groupCourses(course.id,course.BLP_Course_Name__c,course.BLP_Course_Format__c,courseDate ,course.BLP_Mandatory__c));
                    tempList.sort();
                    tempInnerMap.put(course.BLP_Training_Categories__c,tempList);
                }
            }
            if(tempInnerMap.size() > 0){
                groupingMap.put('Others',tempInnerMap);
                trainingPathList.add(new SelectOption('other','Others'));
            }
        }
        
        if(groupingMap.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'There is no course found,change the filter and try again.'));
        }
        
        return groupingMap;
    }
    
    public void filterList(){
        trainingTypeGroupingMap.clear();
        if(sortingSelected == 'A-Z'){
            BLP_CourseListComponentController.Sort_Dir = 'A-Z';
        }
        else if(sortingSelected == 'Z-A'){
            BLP_CourseListComponentController.Sort_Dir = 'Z-A';
        }
        else if(sortingSelected == 'Expirationdate'){
            BLP_CourseListComponentController.Sort_Dir = 'Expirationdate';
        }
        trainingTypeGroupingMap = getCoursesByGrouping(inputSearchText, TraingTypeSelected, TraingPathSelected);
    }
    
    public pagereference redirectUser(){
        if(selectedCourseId != null && selectedCourseId != ''){
            BLP_UtilityController helper = new BLP_UtilityController();
            return helper.redirectUserCommon(selectedCourseId);
        }
        return null;
    }
    
    public class groupCourses implements Comparable{
        public string courseId{get;set;}
        public string courseName{get;set;}
        public string Type{get;set;}
        public String trainingDate{get;set;}
        public boolean isMandatory{get;set;}
        
        public groupCourses(string courseId, string courseName, string Type, String trainingDate, boolean isMandatory){
            this.courseId = courseId;
            this.courseName = courseName;
            this.Type = Type;
            this.trainingDate = trainingDate;
            this.isMandatory = isMandatory;
        }
        
        public Integer compareTo(Object other){
            String otherName = other != null ? ((groupCourses) other).courseName: '';  
            
            Integer returnValue = 0;
            
            if (Sort_Dir == 'A-Z'){
                returnValue = this.courseName.compareTo(otherName);
            }
            else if (Sort_Dir == 'Z-A'){
                returnValue = this.courseName.compareTo(otherName) * (-1);
            }
            else if (Sort_Dir == 'Expirationdate' && this.trainingDate != null){
                String trainingDateOther = (other != null && ((groupCourses) other).trainingDate != null ) ? ((groupCourses) other).trainingDate: '';  
                returnValue = this.trainingDate.compareTo(trainingDateOther) ;
            }
            
            return returnValue;
        }
    }
    
}