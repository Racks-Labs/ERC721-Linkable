import { z, ZodFormattedError } from "zod";
import dotenv from "dotenv";

dotenv.config();

export const envSchema = z.object({
  MRC_BLOCKNUMBER: z.coerce
    .number()
    .transform((n) => {
      if (n === 0) {
        return undefined;
      }
      return n;
    })
    .default(35079287),
  ALCHEMY_POLYGON: z
    .string()
    .url()
    .transform((s) => {
      if (s === "") {
        return undefined;
      }
      return s;
    })
    .default("https://polygon-rpc.com/"),
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
