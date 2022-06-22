package org.goldenaxe.datavis;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;
import java.io.File;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;


public record DataVisConfiguration(
        LinkedHashMap<String, Animation> animations,
        LinkedHashMap<String, MapFile> maps
)
{
    public static DataVisConfiguration read(File configFile)
    {
        ObjectMapper mapper = new ObjectMapper(new YAMLFactory());
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
        DMA,
        PRE_LOADED
    }

    public record Animation(
            AnimationType type,
            long boundsTableAddress,
            long animationTableAddress,
            int animationIndex,
            int animationCount,
            List<Long> tileDataAddresses,
            long paletteAddress
    )
    {
    }

    public record MapFile(
            long address,
            @JsonProperty("base-y-table-address") int baseYTableAddress,
            @JsonProperty("custom-entity-trigger-lists") List<CustomEntityTriggerList> customEntityTriggerLists,
            @JsonProperty("custom-entity-load-groups") List<Integer> customEntityLoadGroupAddresses)
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
}
