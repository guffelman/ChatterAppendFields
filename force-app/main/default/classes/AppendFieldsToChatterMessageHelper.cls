public class AppendFieldsToChatterHelper {
    public static Object getNestedFieldValue(SObject parentObject, String fieldPath) {
        List<String> fieldParts = fieldPath.split('\\.');
        SObject currentObject = parentObject;
        Object fieldValue = null;

        for (Integer i = 0; i < fieldParts.size(); i++) {
            String currentField = fieldParts[i].trim();
            System.debug('Processing nested field: ' + currentField);

            if (currentObject == null) {
                System.debug('Current object is null, cannot retrieve further nested fields.');
                break;
            }

            if (i == fieldParts.size() - 1) {
                // Last part of the field path, retrieve the value
                fieldValue = currentObject.get(currentField);
                System.debug('Retrieved field value: ' + fieldValue);
            } else {
                // Not the last part, retrieve the nested SObject
                currentObject = currentObject.getSObject(currentField);
                System.debug('Retrieved nested object: ' + currentObject);
            }
        }

        return fieldValue;
    }
}