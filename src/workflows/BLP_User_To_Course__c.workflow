<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BLP Notification User Request for Course has been declined</fullName>
        <protected>false</protected>
        <recipients>
            <field>BLP_User__c</field>
            <type>userLookup</type>
        </recipients>
        <template>BLP_Email_Templates/BLP_Notify_User_Request_Decline</template>
    </alerts>
    <alerts>
        <fullName>BLP Notify User For Remaining Prework Postwork</fullName>
        <protected>false</protected>
        <recipients>
            <field>BLP_User__c</field>
            <type>userLookup</type>
        </recipients>
        <template>BLP_Email_Templates/BLP_Remainder_For_Prework</template>
    </alerts>
    <alerts>
        <fullName>BLP Registered Course Email Notification</fullName>
        <protected>false</protected>
        <recipients>
            <field>BLP_User__c</field>
            <type>userLookup</type>
        </recipients>
        <template>unfiled$public/BLP_Course_Registration</template>
    </alerts>
    <alerts>
        <fullName>BLP Registered For Course</fullName>
        <protected>false</protected>
        <recipients>
            <field>BLP_User__c</field>
            <type>userLookup</type>
        </recipients>
        <template>BLP_Email_Templates/BLP_Course_Registered</template>
    </alerts>
    <alerts>
        <fullName>BLP Training Dates Added</fullName>
        <protected>false</protected>
        <recipients>
            <field>BLP_User__c</field>
            <type>userLookup</type>
        </recipients>
        <template>BLP_Email_Templates/BLP_Training_Dates_Added</template>
    </alerts>
    <alerts>
        <fullName>BLP Training Dates Updated</fullName>
        <protected>false</protected>
        <recipients>
            <field>BLP_User__c</field>
            <type>userLookup</type>
        </recipients>
        <template>BLP_Email_Templates/BLP_Training_Dates_Updated</template>
    </alerts>
    <rules>
        <fullName>BLP Course Register</fullName>
        <actions>
            <name>BLP Registered Course Email Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>BLP_User_To_Course__c.BLP_Status__c</field>
            <operation>equals</operation>
            <value>Registered</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BLP Notify User on Course Decline</fullName>
        <actions>
            <name>BLP Notification User Request for Course has been declined</name>
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
    <rules>
        <fullName>BLP Waitlisted Join</fullName>
        <active>false</active>
        <criteriaItems>
            <field>BLP_User_To_Course__c.BLP_Status__c</field>
            <operation>equals</operation>
            <value>Waitlisted</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
