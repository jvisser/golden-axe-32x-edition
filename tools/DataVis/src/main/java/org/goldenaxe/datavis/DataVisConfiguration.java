package org.goldenaxe.datavis;

import com.fasterxml.jackson.databind.BeanDescription;
import com.fasterxml.jackson.databind.DeserializationConfig;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.deser.SettableBeanProperty;
import com.fasterxml.jackson.databind.deser.ValueInstantiator;
import com.fasterxml.jackson.databind.deser.ValueInstantiators;
import com.fasterxml.jackson.databind.deser.std.StdValueInstantiator;
import com.fasterxml.jackson.databind.introspect.BeanPropertyDefinition;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;
import io.kaitai.struct.KaitaiStream;
import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.goldenaxe.datavis.render.AnimationsRenderer;
import org.goldenaxe.datavis.render.DMAAnimationsRenderer;
import org.goldenaxe.datavis.render.PreLoadAnimationsRenderer;


public record DataVisConfiguration(
        LinkedHashMap<String, Animation> animations,
        LinkedHashMap<String, MapFile> maps
)
{

    public static DataVisConfiguration read(File configFile)
    {
        ObjectMapper mapper = new ObjectMapper(new YAMLFactory())
                .registerModule(new RecordNamingStrategyPatchModule())
                .setPropertyNamingStrategy(PropertyNamingStrategies.KEBAB_CASE);
        try
        {
            return mapper.readValue(configFile, DataVisConfiguration.class);
        }
        catch (IOException e)
        {
            throw new ConfigurationException(e);
        }
    }

    public static class ConfigurationException extends RuntimeException
    {
        public ConfigurationException(Throwable cause)
        {
            super(cause);
        }
    }

    public enum AnimationType
    {
        DMA {
            @Override
            AnimationsRenderer createRenderer(KaitaiStream source, Animation config, int spriteMargin)
            {
                return new DMAAnimationsRenderer(source, config, spriteMargin);
            }
        },
        PRE_LOADED {
            @Override
            AnimationsRenderer createRenderer(KaitaiStream source, Animation config, int spriteMargin)
            {
                return new PreLoadAnimationsRenderer(source, config, spriteMargin);
            }
        };

        abstract AnimationsRenderer createRenderer(KaitaiStream source, Animation config, int spriteMargin);
    }

    public record Animation(
            AnimationType type,
            long animationTableAddress,
            int animationIndex,
            int animationCount,
            List<Long> tileDataAddresses,
            boolean tileDataCompressed,
            long boundsTableAddress,
            long paletteAddress,
            long dmaFrameTableAddress
    )
    {
    }

    public record MapFile(
            long address,
            int baseYTableAddress,
            List<CustomEntityTriggerList> customEntityTriggerLists,
            List<Integer> customEntityLoadGroupAddresses)
    {
        private static final long ENTITY_LOAD_SLOT_DESCRIPTOR_TABLE_ADDRESS = 0x37AEE;
        private static final long ENTITY_GROUP_GRAPHICS_TABLE_ADDRESS = 0x13A98;
        private static final long ENTITY_GROUP_PALETTE_TABLE_ADDRESS = 0x389E8;
        private static final long ENTITY_GROUP_TILE_ADDRESS_TABLE = 0x13A74;

        public long getEntityLoadSlotDescriptorTableAddress()
        {
            return ENTITY_LOAD_SLOT_DESCRIPTOR_TABLE_ADDRESS;
        }

        public long getEntityGroupGraphicsTableAddress()
        {
            return ENTITY_GROUP_GRAPHICS_TABLE_ADDRESS;
        }

        public long getEntityGroupPaletteTableAddress()
        {
            return ENTITY_GROUP_PALETTE_TABLE_ADDRESS;
        }

        public long getEntityGroupTileAddressTable()
        {
            return ENTITY_GROUP_TILE_ADDRESS_TABLE;
        }
    }

    public record CustomEntityTriggerList(String name, int address) {}

    private static class RecordNamingStrategyPatchModule extends SimpleModule
    {

        @Override
        public void setupModule(SetupContext context)
        {
            context.addValueInstantiators(new RecordNamingStrategyPatchModule.ValueInstantiatorsModifier());
            super.setupModule(context);
        }

        /**
         * Remove when the following issue is resolved:
         * <a href="https://github.com/FasterXML/jackson-databind/issues/2992">Properties naming strategy do not work with
         * Record #2992</a>
         */
        private static class ValueInstantiatorsModifier extends ValueInstantiators.Base
        {
            @Override
            public ValueInstantiator findValueInstantiator(
                    DeserializationConfig config, BeanDescription beanDesc, ValueInstantiator defaultInstantiator
            )
            {
                if (!beanDesc.getBeanClass().isRecord() || !(defaultInstantiator instanceof StdValueInstantiator) ||
                    !defaultInstantiator.canCreateFromObjectWith())
                {
                    return defaultInstantiator;
                }
                Map<String, BeanPropertyDefinition> map = beanDesc.findProperties().stream().collect(
                        Collectors.toMap(BeanPropertyDefinition::getInternalName, Function.identity()));
                SettableBeanProperty[] renamedConstructorArgs =
                        Arrays.stream(defaultInstantiator.getFromObjectArguments(config))
                                .map(p ->
                                     {
                                         BeanPropertyDefinition prop = map.get(p.getName());
                                         return prop != null ? p.withName(prop.getFullName()) : p;
                                     })
                                .toArray(SettableBeanProperty[]::new);

                return new RecordNamingStrategyPatchModule.PatchedValueInstantiator((StdValueInstantiator) defaultInstantiator, renamedConstructorArgs);
            }
        }

        private static class PatchedValueInstantiator extends StdValueInstantiator
        {

            protected PatchedValueInstantiator(StdValueInstantiator src, SettableBeanProperty[] constructorArguments)
            {
                super(src);
                _constructorArguments = constructorArguments;
            }
        }
    }
}
