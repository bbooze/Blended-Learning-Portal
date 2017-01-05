public class BLP_HeaderController {
  Public List<BLP_Quick_Link__c> quickLinksList {get;set;}
  Public Map<String, String> languageLocaleMap;
  public Map<String, BLP_Language_Setting__c> languagesMap;
  //Constructor
  public BLP_HeaderController() {
    quickLinksList = new List<BLP_Quick_Link__c>();
    languageLocaleMap = new Map<String, String>();
    languagesMap = BLP_Language_Setting__c.getAll();
    populateLanguageLocaleMap();
    getQuickLinks();
  }
  
  //Method to create the languageLocaleMap
  public void populateLanguageLocaleMap() {
    Schema.DescribeFieldResult fieldResult = CategoryNodeLocalization.Language.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry f : ple)
    {
      languageLocaleMap.put(f.getValue(), f.getLabel());
    }
  }
  
  //Method to get the Quick Links from custom metadata
  public void getQuickLinks() {
    User currentUser = [SELECT Id, Name, Profile.Name, LocaleSidKey,
                               (SELECT Id, Name FROM Training_Paths__r)
                        FROM User 
                        WHERE Id = :UserInfo.getUserId()];
                      
    Set<String> trainingPathIdSet = new Set<String>();
    for (BLP_Training_Path__c trainPath : currentUser.Training_Paths__r) {
      trainingPathIdSet.add(trainPath.Id);
    }
    system.debug('currentUserr '+currentUser.Profile.Name+' '+currentUser);
    
    Set<BLP_Quick_Link__c> quickLinksSet = new Set<BLP_Quick_Link__c>();

    for (BLP_Quick_Link__c quickLink : [SELECT Id, Name, BLP_Affiliate__c, BLP_Link_URL__c, BLP_Name_of_Link__c, 
                                               BLP_Global_Link__c, BLP_Profile__c, BLP_Training_Path__c
                                        FROM BLP_Quick_Link__c
                                        WHERE (BLP_Profile__c = Null 
                                               OR BLP_Profile__c = :currentUser.Profile.Name)]) {
      if (quickLink.BLP_Global_Link__c == True) {
        quickLinksSet.add(quickLink);
      } 
      if (quickLink.BLP_Profile__c == currentUser.Profile.Name) {
        quickLinksSet.add(quickLink);
      }
      if (quickLink.BLP_Training_Path__c != Null 
          && trainingPathIdSet.contains(quickLink.BLP_Training_Path__c)) {
        quickLinksSet.add(quickLink);
      } 
      //if (quickLink.BLP_Affiliate__c != Null && languageLocaleMap.get(currentUser.LocaleSidKey).contains(quickLink.BLP_Affiliate__c)) {
      if (quickLink.BLP_Affiliate__c != Null && languagesMap.get(UserInfo.getLanguage()).Corresponding_Language__c == (quickLink.BLP_Affiliate__c)) {
        quickLinksSet.add(quickLink);
      }
    }
    quickLinksList.addAll(quickLinksSet);
    system.debug('quickLinksListt '+quickLinksList);
  }
}