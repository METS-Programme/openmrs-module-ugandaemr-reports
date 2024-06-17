package org.openmrs.module.ugandaemrreports.web.resources;

import org.openmrs.api.APIAuthenticationException;
import org.openmrs.module.ugandaemrreports.web.resources.mapper.ConceptMapper;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import java.lang.reflect.Field;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * End point will handle dataSet evaluation passed
 */
@Controller
@RequestMapping(value = "/rest/" + RestConstants.VERSION_1 + GetOpenmrsClassAttributesController.UGANDAEMRREPORTS + GetOpenmrsClassAttributesController.DATA_SET)
public class GetOpenmrsClassAttributesController {
    public static final String UGANDAEMRREPORTS = "/ugandaemrreports";
    public static final String DATA_SET = "/attributes";

    @ExceptionHandler(APIAuthenticationException.class)
    @RequestMapping(method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<Object> getAttributes(@RequestParam("name") String className) {
        List<String> attributeNames = new ArrayList<>();

        try {
            String fullClassName = "org.openmrs." + className;
            Class<?> clazz = Class.forName(fullClassName);
            Field[] fields = clazz.getDeclaredFields();

            for (Field field : fields) {
                attributeNames.add(field.getName());
            }
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }

        return new ResponseEntity<Object>(attributeNames, HttpStatus.OK);
    }



}