package org.goldenaxe.datavis.render;

import com.google.common.collect.ArrayListMultimap;
import java.awt.image.BufferedImage;
import java.util.List;


public interface AnimationsRenderer
{
    List<ArrayListMultimap<String, BufferedImage>> renderAnimations();
}
