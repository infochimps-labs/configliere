package com.infochimps.config;

import com.infochimps.util.HttpHelper;
import com.infochimps.vayacondios.ItemSets;
import com.infochimps.vayacondios.StandardVCDLink;
import com.infochimps.vayacondios.VayacondiosClient;

import static com.infochimps.util.CurrentClass.getLogger;
import static com.infochimps.vayacondios.ItemSets.Item;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

import java.util.Iterator;

import org.slf4j.Logger;

public class Configliere {
  public static void loadFlatItemSet(String topic, String id) {
    loadFlatItemSet(propertyOrDie("vayacondios.organization"), topic, id);
  }

  public static void loadFlatItemSet(String orgName, String topic, String id) {
    loadFlatItemSet(orgName, topic, id, Boolean.FALSE);
  }

  public static void loadFlatItemSet(String orgName, String topic, String id, Boolean withOrg) {
    ItemSets org = organizations.get(orgName);
    StandardVCDLink
      .forceLegacy(Boolean.valueOf(propertyOr("vayacondios.legacy", "false")));
    if (org == null) {
      org = (new VayacondiosClient(
                  propertyOrDie("vayacondios.host"),
                  Integer.parseInt(propertyOrDie("vayacondios.port"))).
             organization(orgName).
             itemsets());

      organizations.put(orgName, org);
    }

    StringBuilder builder = new StringBuilder();

    List<Item> items = null;
    try { items = org.fetch(topic, id); }
    catch (IOException ex) {
      LOG.warn("error loading " + topic + "." + id + " from vayacondios:", ex);
      return;
    }

    String propertyName = topic + "." + id;
    if (withOrg) {
      propertyName = orgName + "." + propertyName;
    }

    if (items.size() == 0) System.setProperty(propertyName, "");
    else {
      Iterator<Item> iter = items.iterator();
      builder.append(iter.next().getObject().toString());
      while (iter.hasNext())
        builder.append(JOIN).append(iter.next().getObject().toString());

      System.setProperty(propertyName, builder.toString());
    }
  }

  public static void loadConfigFileOrDie(String name) {
    try {
      System.err.println("loading config from: " + name);
      System.getProperties().load(new FileReader(name));
    } catch (FileNotFoundException ex) {
      throw new AssertionError(ex);
    } catch (IOException ex) {
      throw new AssertionError(ex);
    }
  }

  public static String propertyOr(String name, String alternative) {
    String property = System.getProperty(name);
    return (property == null) ? alternative : property;
  }

  public static String propertyOrDie(String name) {
    String property = System.getProperty(name);
    // Java assertions are disabled by default, so do this instead.
    if (property == null)
      throw new AssertionError("property " + name + " not provided");
    return property;
  }

  private static final String JOIN = ",";
  private static Map<String, ItemSets> organizations =
    new HashMap<String, ItemSets>();
  private static final Logger LOG = getLogger();
}