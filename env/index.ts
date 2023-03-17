import { z, ZodFormattedError } from "zod";
import dotenv from "dotenv";

dotenv.config();

export const envSchema = z.object({
  MRC_BLOCKNUMBER: z.coerce
    .number()
    .min(1)
    .catch(() => {
      console.log("MRC_BLOCKNUMBER not found/not valid, using default value");
      return 35079287;
    }),
  ALCHEMY_POLYGON: z
    .string()
    .url()
    .catch(() => {
      console.log("ALCHEMY_POLYGON not found/not valid, using default value");
      return "https://polygon.llamarpc.com";
    }),
  TEST_LOCAL_BLOCKCHAIN: z
    .enum(["true", "false"])
    .default("false")
    .transform((v) => v === "true"),
});

export const formatErrors = (
  errors: ZodFormattedError<Map<string, string>, string>,
) =>
  Object.entries(errors)
    .map(([name, value]) => {
      if (value && "_errors" in value)
        return `${name}: ${value._errors.join(", ")}\n`;
    })
    .filter(Boolean);

const _env = envSchema.safeParse(process.env);

if (!_env.success) {
  console.error(
    "❌ Invalid environment variables:\n",
    ...formatErrors(_env.error.format()),
  );
  throw new Error("Invalid environment variables");
}

export const env = _env.data;
