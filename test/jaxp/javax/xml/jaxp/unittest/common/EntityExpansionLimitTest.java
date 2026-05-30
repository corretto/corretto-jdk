/*
 * Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 */

/*
 * @test
 * @library /javax/xml/jaxp/unittest
 * @summary Verifies that totalEntitySizeLimit stops entity expansion attacks
 *          while staying within the default entityExpansionLimit (2500).
 *          Uses a large entity referenced multiple times so total size exceeds
 *          totalEntitySizeLimit without exceeding entityExpansionLimit.
 *          Warning: this test was developed with a help of generative AI
 * @run main/othervm -Dtest.parser=sax -Dtest.entitySize=200000 -Dtest.refCount=1 -Dtest.expectFailure=false common.EntityExpansionLimitTest
 * @run main/othervm -Dtest.parser=sax -Dtest.entitySize=25000 -Dtest.refCount=2500 -Dtest.expectFailure=true common.EntityExpansionLimitTest
 * @run main/othervm -Dtest.parser=sax -Dtest.entitySize=25000 -Dtest.refCount=2500 -Dtest.expectFailure=true -Djdk.xml.totalEntitySizeLimit=50000000 common.EntityExpansionLimitTest
 * @run main/othervm -Dtest.parser=sax -Dtest.entitySize=10000 -Dtest.refCount=10000 -Dtest.expectFailure=true -Djdk.xml.entityExpansionLimit=10000 common.EntityExpansionLimitTest
 * @run main/othervm -Dtest.parser=sax -Dtest.entitySize=10000 -Dtest.refCount=10000 -Dtest.expectFailure=true -Djdk.xml.entityExpansionLimit=0 common.EntityExpansionLimitTest
 */
package common;

import java.io.StringReader;
import javax.xml.parsers.SAXParserFactory;
import org.xml.sax.InputSource;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;

public class EntityExpansionLimitTest {

    /**
     * Builds XML with one large entity referenced refCount times.
     * Total size = entitySize * refCount.
     * Expansion count = refCount (must stay <= entityExpansionLimit).
     */
    private static String buildRepeatedEntityXml(int entitySize, int refCount) {
        StringBuilder sb = new StringBuilder();
        sb.append("<?xml version=\"1.0\"?>\n");
        sb.append("<!DOCTYPE foo [\n");
        sb.append("  <!ENTITY big \"").append("A".repeat(entitySize)).append("\">\n");
        sb.append("]>\n");
        sb.append("<root>");
        for (int i = 0; i < refCount; i++) {
            sb.append("&big;");
        }
        sb.append("</root>");
        return sb.toString();
    }

    public static void main(String[] args) throws Exception {
        int entitySize = Integer.parseInt(System.getProperty("test.entitySize"));
        int refCount = Integer.parseInt(System.getProperty("test.refCount"));
        boolean expectFailure = Boolean.parseBoolean(System.getProperty("test.expectFailure"));
        String xml = buildRepeatedEntityXml(entitySize, refCount);
        try {
            SAXParserFactory.newInstance().newSAXParser()
                    .parse(new InputSource(new StringReader(xml)), new DefaultHandler());
            if (expectFailure) {
                throw new AssertionError("Expected SAXParseException due to totalEntitySizeLimit");
            }
        } catch (SAXParseException e) {
            if (!expectFailure) {
                throw new AssertionError("Unexpected SAXParseException: " + e.getMessage(), e);
            }
            System.out.println("Expansion stopped: " + e.getMessage());
            if (!e.getMessage().contains("totalEntitySizeLimit") &&
                    !e.getMessage().contains("accumulated size")) {
                throw new AssertionError(
                        "Expected totalEntitySizeLimit in message: " + e.getMessage());
            }
        }
    }
}
