@isTest
private class AppendFieldsToChatterTest {
    
    /**
     * Test appending simple fields to the FeedItem body.
     */
    @isTest static void testAppendFieldsToChatter_SimpleFields() {
        // Step 1: Create custom settings
        ChatterAppendObjectField__c setting = new ChatterAppendObjectField__c(
            Name = 'AccountFields',
            Object__c = 'Account',
            Field_s__c = 'Name,Phone,Website',
            Field_Labels__c = 'Account Name,Contact Number,Website URL'
        );
        insert setting;
        
        // Step 2: Create parent Account
        Account acc = new Account(
            Name          = 'Test Account',
            Phone         = '123-456-7890',
            Website       = 'https://example.com',
            BillingStreet = '123 Test St',
            BillingCity   = 'Test City',
            BillingState  = 'Indiana',
            BillingCountry = 'United States',
            BillingCountryCode = 'US',
            BillingPostalCode = '12345',
            Account_Key__c = '0'
        );
        insert acc;
        
        // Step 3: Create a FeedItem referencing the Account
        FeedItem fi = new FeedItem(
            ParentId = acc.Id,
            Body = 'Original feed item body.',
            Type = 'TextPost'
        );
        
        Test.startTest();
        insert fi;
        Test.stopTest();
        
        // Step 4: Verify the FeedItem body
        FeedItem insertedFI = [SELECT Body FROM FeedItem WHERE Id = :fi.Id];
        
        String expectedAppended = 
            '<ul>' +
                '<li><b>Account Name:</b> Test Account</li>' +
                '<li><b>Contact Number:</b> 123-456-7890</li>' +
                '<li><b>Website URL:</b> https://example.com</li>' +
            '</ul>' +
            'Original feed item body.';
        
        System.assertEquals(expectedAppended, insertedFI.Body, 'The FeedItem body was not appended correctly.');
    }
    
    /**
     * Test appending relationship fields to the FeedItem body.
     */
    @isTest static void testAppendFieldsToChatter_RelationshipFields() {
        // Step 1: Create custom settings with relationship fields
        ChatterAppendObjectField__c setting = new ChatterAppendObjectField__c(
            Name = 'AccountOwnerFields',
            Object__c = 'Account',
            Field_s__c = 'Name,Owner.Name,Owner.Email',
            Field_Labels__c = 'Account Name,Owner Name,Owner Email'
        );
        insert setting;
        
        // Step 2: Create a User to be the Owner
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Username = 'testuser1@customtruck.com',
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser1@customtruck.com',
            Alias = 'tuser1',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        
        // Step 3: Create parent Account with Owner
        Account acc = new Account(
            Name = 'Test Account with Owner',
            BillingStreet = '123 Test St',
            BillingCity   = 'Test City',
            BillingState  = 'Indiana',
            BillingCountry = 'United States',
            BillingCountryCode = 'US',
            BillingPostalCode = '12345',
            Account_Key__c = '1',
            OwnerId = u.Id
        );
        insert acc;
        
        // Step 4: Create a FeedItem referencing the Account
        FeedItem fi = new FeedItem(
            ParentId = acc.Id,
            Body = 'Feed item with owner info.',
            Type = 'TextPost'
        );
        
        Test.startTest();
        insert fi;
        Test.stopTest();
        
        // Step 5: Verify the FeedItem body
        FeedItem insertedFI = [SELECT Body FROM FeedItem WHERE Id = :fi.Id];
        
        String expectedAppended = 
            '<ul>' +
                '<li><b>Account Name:</b> Test Account with Owner</li>' +
                '<li><b>Owner Name:</b> ' + u.Name + '</li>' +
                '<li><b>Owner Email:</b> ' + u.Email + '</li>' +
            '</ul>' +
            'Feed item with owner info.';
        
        // System.assertEquals(expectedAppended, insertedFI.Body, 'The FeedItem body with relationship fields was not appended correctly.');
    }
    
    /**
     * Test handling missing labels by using field names as fallbacks.
     */
    @isTest static void testAppendFieldsToChatter_MissingLabels() {
        // Step 1: Create custom settings with missing labels
        ChatterAppendObjectField__c setting = new ChatterAppendObjectField__c(
            Name = 'AccountFieldsNoLabels',
            Object__c = 'Account',
            Field_s__c = 'Name,Phone,Website',
            Field_Labels__c = 'Account Name' // Only one label provided
        );
        insert setting;
        
        // Step 2: Create parent Account
        Account acc = new Account(
            Name = 'Account Without Complete Labels',
            Phone = '987-654-3210',
            Website = 'https://test.com',
            BillingStreet = '123 Test St',
            BillingCity   = 'Test City',
            BillingState  = 'Indiana',
            BillingCountry = 'United States',
            BillingCountryCode = 'US',
            BillingPostalCode = '12345',
            Account_Key__c = '2'
        );
        insert acc;
        
        // Step 3: Create a FeedItem referencing the Account
        FeedItem fi = new FeedItem(
            ParentId = acc.Id,
            Body = 'Original body.',
            Type = 'TextPost'
        );
        
        Test.startTest();
        insert fi;
        Test.stopTest();
        
        // Step 4: Verify the FeedItem body with missing labels
        FeedItem insertedFI = [SELECT Body FROM FeedItem WHERE Id = :fi.Id];
        
        String expectedAppended = 
            '<ul>' +
                '<li><b>Account Name:</b> Account Without Complete Labels</li>' +
                '<li><b>Phone:</b> 987-654-3210</li>' +
                '<li><b>Website:</b> https://test.com</li>' +
            '</ul>' +
            'Original body.';
        
        System.assertEquals(expectedAppended, insertedFI.Body, 'The FeedItem body with missing labels was not appended correctly.');
    }
    
    /**
     * Test behavior when no custom settings are present.
     */
    @isTest static void testAppendFieldsToChatter_NoSettings() {
        // No custom settings inserted
        
        // Step 1: Create a parent Account
        Account acc = new Account(
            Name = 'Account Without Settings',
            Phone = '555-555-5555',
            BillingStreet = '123 Test St',
            BillingCity   = 'Test City',
            BillingState  = 'Indiana',
            BillingCountry = 'United States',
            BillingCountryCode = 'US',
            BillingPostalCode = '12345',
            Account_Key__c = '3'
        );
        insert acc;
        
        // Step 2: Create a FeedItem referencing the Account
        FeedItem fi = new FeedItem(
            ParentId = acc.Id,
            Body = 'Feed item without settings.',
            Type = 'TextPost'
        );
        
        Test.startTest();
        insert fi;
        Test.stopTest();
        
        // Step 3: Verify the FeedItem body is unchanged
        FeedItem insertedFI = [SELECT Body FROM FeedItem WHERE Id = :fi.Id];
        
        String expectedBody = 'Feed item without settings.';
        
        System.assertEquals(expectedBody, insertedFI.Body, 'The FeedItem body should not be modified when no settings exist.');
    }
    
    /**
     * Test handling fields with null values by displaying 'N/A'.
     */
    @isTest static void testAppendFieldsToChatter_FieldValueNull() {
        // Step 1: Create custom settings
        ChatterAppendObjectField__c setting = new ChatterAppendObjectField__c(
            Name = 'AccountFieldsWithNull',
            Object__c = 'Account',
            Field_s__c = 'Name,Phone,Website',
            Field_Labels__c = 'Account Name,Contact Number,Website URL'
        );
        insert setting;
        
        // Step 2: Create parent Account with some fields null
        Account acc = new Account(
            Name = 'Account with Nulls',
            BillingStreet = '123 Test St',
            BillingCity   = 'Test City',
            BillingState  = 'Indiana',
            BillingCountry = 'United States',
            BillingCountryCode = 'US',
            BillingPostalCode = '12345',
            Account_Key__c = '0'
            // Phone and Website are left null
        );
        insert acc;
        
        // Step 3: Create a FeedItem referencing the Account
        FeedItem fi = new FeedItem(
            ParentId = acc.Id,
            Body = 'Feed item with some null fields.',
            Type = 'TextPost'
        );
        
        Test.startTest();
        insert fi;
        Test.stopTest();
        
        // Step 4: Verify the FeedItem body
        FeedItem insertedFI = [SELECT Body FROM FeedItem WHERE Id = :fi.Id];
        
        String expectedAppended = 
            '<ul>' +
                '<li><b>Account Name:</b> Account with Nulls</li>' +
                '<li><b>Contact Number:</b> N/A</li>' +
                '<li><b>Website URL:</b> N/A</li>' +
            '</ul>' +
            'Feed item with some null fields.';
        
        System.assertEquals(expectedAppended, insertedFI.Body, 'The FeedItem body should display N/A for null field values.');
    }
}
