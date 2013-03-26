package com.infochimps.config;

import com.infochimps.config.Configliere;
import static com.infochimps.config.Configliere.propertyOrDie;
import static com.infochimps.vayacondios.ItemSets.ItemSet;
import static com.infochimps.vayacondios.ItemSets.Item;
import com.infochimps.vayacondios.VayacondiosClient;

import java.io.*;
import java.util.*;

public class IntegrationTests {
  final static String VCD_HOST = "localhost";
  final static int VCD_PORT = 8000;
  final static String VCD_TOPIC = "configliere";
  final static String VCD_ID = "samples";

  public static void main(String argv[]) throws IOException {
    VayacondiosClient client = new VayacondiosClient(VCD_HOST, VCD_PORT);

    System.setProperty("vayacondios.host", VCD_HOST);
    System.setProperty("vayacondios.port", Integer.toString(VCD_PORT));

    String result;

    result = populateSet(client, "test_one", "foo", "bar", "baz");
    System.setProperty("vayacondios.organization", "test_one");
    Configliere.loadFlatItemSet(VCD_TOPIC, VCD_ID);
    testProperty(result);

    result = populateSet(client, "test_two", "bif", "bam", "buz");
    Configliere.loadFlatItemSet("test_two", VCD_TOPIC, VCD_ID);
    testProperty(result);

    depopulateSet(client, "test_one");
    depopulateSet(client, "test_two");
  }

  public static void depopulateSet(VayacondiosClient client, String orgName)
    throws IOException {
    client.organization(orgName).itemsets().
      create(VCD_TOPIC, VCD_ID, Collections.EMPTY_LIST);
  }

  public static String populateSet(VayacondiosClient client,
			  String orgName,
			  String... itemStrings) throws IOException {
    ArrayList<Item> items = new ArrayList();
    for (String str : itemStrings) items.add(new Item(str));
    client.organization(orgName).itemsets().create(VCD_TOPIC, VCD_ID, items);
    StringBuilder builder = new StringBuilder();
    builder.append(itemStrings[0]);
    for (int i = 1; i < itemStrings.length; i++) {
      builder.append(",");
      builder.append(itemStrings[i]);
    }
    return builder.toString();
  }

  public static void testProperty(String expected) {
    String propName = VCD_TOPIC + "." + VCD_ID;
    String result = System.getProperty(propName);

    if (result == null)
      System.out.println("\033[31mFAIL\033[0m: system property not populated");
    else if (!result.equals(expected)) {
      System.out.println("\033[31mFAIL\033[0m: result not correct.");
      System.out.println("      expected " + expected + " but saw");
      System.out.println("      " + result);
    } else {
      System.out.println("\033[32mSUCCESS\033[0m saw all expected items");
    }

  }
}
