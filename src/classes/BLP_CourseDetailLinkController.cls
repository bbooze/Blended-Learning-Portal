Public class BLP_CourseDetailLinkController{
    
    public BLP_UtilityController.AdditionalSubscribedCourses subscribedCourseDetail{get;set;}
    
    public BLP_CourseDetailLinkController(){
        string courseId = Apexpages.currentPage().getParameters().get('courseId');
        BLP_UtilityController helper = new BLP_UtilityController();
        subscribedCourseDetail = helper.getSubscribedCourse(courseId);
    }

}