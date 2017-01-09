<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BLP_Course_Summary_Notification_Mail_Alert</fullName>
        <description>BLP Course Summary Notification Mail Alert</description>
        <protected>false</protected>
        <recipients>
            <field>BLP_Course_Expert_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>BLP_Tech_Support_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BLP_Email_Templates/BLP_Course_Summary_Notification_Mail_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>BLP_Update_Course_Expert_Email</fullName>
        <field>BLP_Course_Expert_Email__c</field>
        <formula>BLP_Course__r.BLP_Course_Expert_Email__c</formula>
        <name>BLP Update Course Expert Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BLP_Update_Tech_Support_Email</fullName>
        <field>BLP_Tech_Support_Email__c</field>
        <formula>BLP_Course__r.BLP_Tech_Support_Email__c</formula>
        <name>BLP Update Tech Support Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>BLP Course Summary Notification %28Training Date%29</fullName>
        <actions>
            <name>BLP_Update_Course_Expert_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>BLP_Update_Tech_Support_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>BLP Course Summary Notification (Training Date)</description>
        <formula>NOT( ISNULL( BLP_Course_Summary_Notifications_Date__c ) ) &amp;&amp;  BLP_Training_Date_Time__c &gt; NOW()</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>BLP_Course_Summary_Notification_Mail_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>BLP_Training_Dates__c.BLP_Course_Summary_Notifications_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>BLP Update Tech Support %26 Course Expert Email</fullName>
        <actions>
            <name>BLP_Update_Course_Expert_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>BLP_Update_Tech_Support_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Tech Support &amp; Course Expert Email</description>
        <formula>NOT(ISNULL( BLP_Course__c )) &amp;&amp; NOT(ISNULL(  BLP_Course_Summary_Notifications_Date__c )) &amp;&amp; (ISNEW() || ISCHANGED(BLP_Course__c) || ISCHANGED(BLP_Course_Summary_Notifications_Date__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
