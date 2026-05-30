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
package common.util;

import java.io.StringReader;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.SAXParserFactory;
import org.xml.sax.InputSource;
import org.xml.sax.helpers.DefaultHandler;

/**
 * Common utilities for XML entity limit tests.
 */
public class LimitTestBase {

    /** Builds XML with a single entity of the given character size. */
    public static String buildXml(int entitySize) {
        return "<?xml version=\"1.0\"?>\n" +
                "<!DOCTYPE foo [\n" +
                "  <!ENTITY big \"" + "A".repeat(entitySize) + "\">\n" +
                "]>\n" +
                "<root>&big;</root>";
    }

    /**
     * Builds XML with two entities, each of the given size.
     * Each entity is under maxGeneralEntitySizeLimit individually,
     * but their combined size can exceed totalEntitySizeLimit.
     */
    public static String buildTwoEntityXml(int eachSize) {
        return "<?xml version=\"1.0\"?>\n" +
                "<!DOCTYPE foo [\n" +
                "  <!ENTITY a \"" + "A".repeat(eachSize) + "\">\n" +
                "  <!ENTITY b \"" + "B".repeat(eachSize) + "\">\n" +
                "]>\n" +
                "<root>&a;&b;</root>";
    }

    /**
     * Builds a nested-entity XML where each level doubles the node count.
     * e0 = "A", e_n = "&e_{n-1};&e_{n-1};".
     * Level n produces ~2^n entity replacement nodes.
     */
    public static String buildNestedEntityXml(int levels) {
        StringBuilder sb = new StringBuilder();
        sb.append("<?xml version=\"1.0\"?>\n");
        sb.append("<!DOCTYPE foo [\n");
        sb.append("  <!ENTITY e0 \"A\">\n");
        for (int i = 1; i <= levels; i++) {
            sb.append("  <!ENTITY e").append(i)
              .append(" \"&e").append(i - 1).append(";&e").append(i - 1).append(";\">\n");
        }
        sb.append("]>\n");
        sb.append("<root>&e").append(levels).append(";</root>");
        return sb.toString();
    }

    /**
     * Returns the minimum number of nesting levels needed to exceed the given limit.
     * Each level produces ~2^n nodes.
     */
    public static int levelsToExceed(int limit) {
        return (int) Math.ceil(Math.log(limit + 1) / Math.log(2)) + 1;
    }

    /**
     * Parses XML using DOM or SAX based on the test.parser system property.
     * Defaults to DOM if not set.
     */
    public static void parse(String xml) throws Exception {
        InputSource src = new InputSource(new StringReader(xml));
        if ("sax".equals(System.getProperty("test.parser"))) {
            SAXParserFactory.newInstance().newSAXParser()
                    .parse(src, new DefaultHandler());
        } else {
            DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(src);
        }
    }
}
