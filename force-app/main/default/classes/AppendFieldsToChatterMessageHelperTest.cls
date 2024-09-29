@isTest
public class AppendFieldsToChatterHelperTest {
    
    // Setup test data once for all test methods
    @testSetup
    static void setupTestData() {
        // Retrieve a Profile ID (Standard User Profile)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        

        // Create a User to own the Account
        User ownerUser = new User(
            Username             = 'testuser1@customtruck.com',
            Alias                = 'tuser1',
            Email                = 'testuser1@customtruck.com',
            EmailEncodingKey     = 'UTF-8',
            LastName             = 'User',
            LanguageLocaleKey    = 'en_US',
            LocaleSidKey         = 'en_US',
            ProfileId            = p.Id,
            TimeZoneSidKey       = 'America/Los_Angeles'
        );
        insert ownerUser;

        Account acc = new Account(
            Name          = 'Test Account',
            OwnerId       = ownerUser.Id,
            BillingStreet = '123 Test St',
            BillingCity   = 'Test City',
            BillingState  = 'Indiana',
            BillingCountry = 'United States',
            BillingCountryCode = 'US',
            BillingPostalCode = '12345',
            Account_Key__c = '0'
        );
        insert acc;
        
        // Create a Contact related to the Account
        Contact con = new Contact(
            FirstName = 'Test',
            LastName  = 'Contact',
            AccountId = acc.Id,
            OwnerId   = ownerUser.Id
        );
        insert con;
    }
    
    /**
     * Test retrieving a simple field value from an Account.
     */
    @isTest
    static void testGetNestedFieldValue_SimpleField() {
        // Retrieve the Account record
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        
        // Use the helper method to get the 'Name' field
        Object name = AppendFieldsToChatterHelper.getNestedFieldValue(acc, 'Name');
        
        // Assert that the retrieved name matches the expected value
        System.assertEquals('Test Account', name, 'The account name should be "Test Account".');
    }
    
    /**
     * Test retrieving a nested field value (Owner.Name) from an Account.
     */
    @isTest
    static void testGetNestedFieldValue_NestedField() {
        // Retrieve the Account with Owner information
        Account acc = [SELECT Id, Owner.Name FROM Account LIMIT 1];
        
        // Use the helper method to get the 'Owner.Name' field
        Object ownerName = AppendFieldsToChatterHelper.getNestedFieldValue(acc, 'Owner.Name');
        
        // Retrieve the actual Owner's name for comparison
        User owner = [SELECT Name FROM User WHERE Id = :acc.OwnerId LIMIT 1];
        
        // Assert that the retrieved owner name matches the expected value
        System.assertEquals(owner.Name, ownerName, 'The owner name should match the user name.');
    }
    
    /**
     * Test retrieving a multiple-level nested field value (Account.Owner.Name) from a Contact.
     */
    @isTest
    static void testGetNestedFieldValue_MultipleNestedFields() {
        // Retrieve the Contact with related Account and Owner information
        Contact con = [SELECT Id, Account.Owner.Name FROM Contact LIMIT 1];
        
        // Use the helper method to get the 'Account.Owner.Name' field
        Object ownerName = AppendFieldsToChatterHelper.getNestedFieldValue(con, 'Account.Owner.Name');
        
        // Retrieve the actual Owner's name for comparison
        Account acc = [SELECT Owner.Name FROM Account WHERE Id = :con.AccountId LIMIT 1];
        User owner = [SELECT Name FROM User WHERE Name = :acc.Owner.Name LIMIT 1];
        
        // Assert that the retrieved owner name matches the expected value
        System.assertEquals(owner.Name, ownerName, 'The account owner name should match.');
    }
    
    /**
     * Test handling of an invalid field path.
     */
    // @isTest
    // static void testGetNestedFieldValue_InvalidFieldPath() {
    //     // Retrieve the Account record
    //     Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        
    //     // Use the helper method with an invalid field path
    //     Object invalid = AppendFieldsToChatterHelper.getNestedFieldValue(acc, 'NonExistentField');
        
    //     // Assert that the result is null for an invalid field path
    //     System.assertEquals(null, invalid, 'Invalid field path should return null.');
    // }
    
    /**
     * Test handling when the parent SObject is null.
     */
    @isTest
    static void testGetNestedFieldValue_NullParentObject() {
        // Call the helper method with a null parent object
        Object result = AppendFieldsToChatterHelper.getNestedFieldValue(null, 'Name');
        
        // Assert that the result is null
        System.assertEquals(null, result, 'Result should be null when parent object is null.');
    }
    
    /**
     * Test handling when an intermediate SObject in the field path is null.
     */
    @isTest
    static void testGetNestedFieldValue_NullIntermediateObject() {
        // Create an Account without a Parent Account (ParentId is null)
        Account childAcc = new Account(
            Name      = 'Child Account',
            ParentId  = null,
            BillingStreet = '1234 Test St',
            BillingCity   = 'Test City2',
            BillingState  = 'Indiana',
            BillingCountry = 'United States',
            BillingCountryCode = 'US',
            BillingPostalCode = '12345',
            Account_Key__c = '0'
        );
        insert childAcc;
        
        // Use the helper method to get 'Parent.Name', which should be null
        Object parentName = AppendFieldsToChatterHelper.getNestedFieldValue(childAcc, 'Parent.Name');
        
        // Assert that the result is null since Parent is null
        System.assertEquals(null, parentName, 'Parent is null, so Parent.Name should be null.');
    }
}
