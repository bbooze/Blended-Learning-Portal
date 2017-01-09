<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BLP_Notification_User_Request_for_Course_has_been_declined</fullName>
        <description>BLP Notification User Request for Course has been declined</description>
        <protected>false</protected>
        <recipients>
            <field>BLP_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BLP_Email_Templates/BLP_Notify_User_Request_Decline</template>
    </alerts>
    <alerts>
        <fullName>BLP_Notify_User_For_Remaining_Prework_Postwork</fullName>
        <description>BLP Notify User For Remaining Prework Postwork</description>
        <protected>false</protected>
        <recipients>
            <field>BLP_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BLP_Email_Templates/BLP_Remainder_For_Prework</template>
    </alerts>
    <alerts>
        <fullName>BLP_Registered_For_Course</fullName>
        <description>BLP Registered For Course</description>
        <protected>false</protected>
        <recipients>
            <field>BLP_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BLP_Email_Templates/BLP_Course_Registered</template>
    </alerts>
    <alerts>
        <fullName>BLP_Training_Dates_Added</fullName>
        <description>BLP Training Dates Added</description>
        <protected>false</protected>
        <recipients>
            <field>BLP_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BLP_Email_Templates/BLP_Training_Dates_Added</template>
    </alerts>
    <alerts>
        <fullName>BLP_Training_Dates_Updated</fullName>
        <description>BLP Training Dates Updated</description>
        <protected>false</protected>
        <recipients>
            <field>BLP_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BLP_Email_Templates/BLP_Training_Dates_Updated</template>
    </alerts>
    <rules>
        <fullName>BLP Notify User on Course Decline</fullName>
        <actions>
            <name>BLP_Notification_User_Request_for_Course_has_been_declined</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>BLP_User_To_Course__c.BLP_Status__c</field>
            <operation>equals</operation>
            <value>Removed</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
