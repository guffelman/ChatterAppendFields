# AppendFieldsToChatterMessage

## Overview

`AppendFieldsToChatterMessage` is an Apex trigger designed to append specific fields from a parent object to a Chatter message in Salesforce. This trigger is particularly useful for enhancing Chatter posts with additional context by including relevant fields from related records.

## Features

- Appends fields from parent objects to Chatter messages.
- Supports both direct and relationship fields.
- Customizable through custom settings.
- Handles errors gracefully and ensures Chatter messages are still posted even if some fields cannot be retrieved.

## Custom Settings

The trigger relies on a custom setting `ChatterAppendObjectField__c` to determine which fields to append. The custom setting should have the following fields:
- Object__c: The API name of the object whose fields should be appended.
- Field_s__c: A comma-separated list of field API names to append.
- Field_Labels__c: (Optional) A comma-separated list of labels for the fields. If not provided, the field API names will be used as labels.


## Installation

1. **Deploy the Apex Trigger:**
   - Deploy the `AppendFieldsToChatterMessage.cls`file to your Salesforce org.

2. **Create Custom Settings:**
   - Navigate to Setup > Custom Settings.
   - Create a new custom setting named `ChatterAppendObjectField__c`
   - Add fields `Object__c`, `Field_s__c`, and `Field_Labels__c` to the custom setting.

3. **Configure Custom Settings:**
   - Add records to the `ChatterAppendObjectField__c` custom setting for each object you want to append fields from.
   - Specify the object API name, fields, and optional field labels.

## Usage

Once installed and configured, the trigger will automatically append the specified fields to any Chatter message related to the configured objects.

## Example

Suppose you have a custom setting configured as follows:

- `Object__c`: `Account`
- `Field_s__c`: `Name,Industry,AnnualRevenue`
- `Field_Labels__c`: `Account Name,Industry,Revenue`

When a Chatter post is created related to an `Account` record, the trigger will append the following information to the Chatter message:

```
<ul>
  <li><b>Account Name:</b> Acme Corporation</li>
  <li><b>Industry:</b> Manufacturing</li>
  <li><b>Revenue:</b> $10,000,000</li>
</ul>
```

## Error Handling

The trigger includes error handling to ensure that if any field cannot be retrieved, it will display `N/A` instead of failing the entire process. Errors are logged using `System.debug`.

## Contributing

Contributions are welcome! Please fork the repository and submit pull requests for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contact

For any questions or support, please contact the project maintainer.
