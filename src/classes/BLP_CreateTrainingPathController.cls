Public class BLP_CreateTrainingPathController{
    
    public string serchCurriculumStr{get;set;}
    public string serchCourseStr{get;set;}
    
    public BLP_CreateTrainingPathController(Apexpages.Standardcontroller stdController){
        serchCurriculumStr = '';
        serchCourseStr = 'c';
    }
    
    public list<CurriculumDataWrapper> getSearchedCurriculums(){
        list<CurriculumDataWrapper> curriculum = new list<CurriculumDataWrapper>();
        if(serchCurriculumStr != null && serchCurriculumStr != ''){
            serchCurriculumStr = '%' + serchCurriculumStr + '%';
            list<BLP_Course_To_Curriculum__c> ctcList = [select id, name, BLP_Curriculum__r.name, BLP_Curriculum__r.BLP_Curriculum_Title__c, BLP_Curriculum__c from BLP_Course_To_Curriculum__c where BLP_Curriculum__r.name like : serchCurriculumStr];
            for(BLP_Course_To_Curriculum__c ctc : ctcList){
                if(ctc.BLP_Curriculum__c != null && ctc.BLP_Curriculum__r.name != null){
                    CurriculumDataWrapper wrap = new CurriculumDataWrapper();
                    wrap.curriculumName = ctc.BLP_Curriculum__r.name;
                    wrap.curriculumTitle = ctc.BLP_Curriculum__r.BLP_Curriculum_Title__c;
                    wrap.order = 1;
                    curriculum.add(wrap);
                }
            }
        }
        return curriculum;
    }
    
    public list<CourseDataWrapper> getSearchedCourses(){
        list<CourseDataWrapper> courses = new list<CourseDataWrapper>();
        if(serchCourseStr != null && serchCourseStr != ''){
            serchCourseStr = '%' + serchCourseStr + '%';
            list<BLP_Course__c> couList = [select id, name, BLP_Course_Name__c from BLP_Course__c where BLP_Course_Name__c like : serchCourseStr];
            for(BLP_Course__c cou : couList){
                if(cou.BLP_Course_Name__c != null){
                    CourseDataWrapper wrap = new CourseDataWrapper();
                    wrap.courseName = cou.BLP_Course_Name__c;
                    wrap.courseId = cou.Id;
                    courses.add(wrap);
                }
            }
        }
        return courses;
    }
    
    public class CurriculumDataWrapper{
        Public string curriculumName{get;set;}
        Public string curriculumTitle{get;set;}
        Public integer order{get;set;}
        
    }
    
    public class CourseDataWrapper{
        Public string courseName{get;set;}
        Public string courseId{get;set;}
        
    }
}