"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deploy = void 0;
const clc = require("cli-color");
const tmp_1 = require("tmp");
const api_1 = require("../../api");
const gcp = require("../../gcp");
const utils_1 = require("../../utils");
const prepareFunctionsUpload = require("../../prepareFunctionsUpload");
const checkIam_1 = require("./checkIam");
const GCP_REGION = api_1.functionsUploadRegion;
tmp_1.setGracefulCleanup();
async function uploadSource(context, source) {
    const uploadUrl = await gcp.cloudfunctions.generateUploadUrl(context.projectId, GCP_REGION);
    context.uploadUrl = uploadUrl;
    const apiUploadUrl = uploadUrl.replace("https://storage.googleapis.com", "");
    await gcp.storage.upload(source, apiUploadUrl);
}
async function deploy(context, options, payload) {
    if (options.config.get("functions")) {
        utils_1.logBullet(clc.cyan.bold("functions:") +
            " preparing " +
            clc.bold(options.config.get("functions.source")) +
            " directory for uploading...");
        const source = await prepareFunctionsUpload(context, options);
        context.existingFunctions = await gcp.cloudfunctions.listAll(context.projectId);
        payload.functions = {
            triggers: options.config.get("functions.triggers"),
        };
        await checkIam_1.checkHttpIam(context, options, payload);
        if (!source) {
            return;
        }
        try {
            await uploadSource(context, source);
            utils_1.logSuccess(clc.green.bold("functions:") +
                " " +
                clc.bold(options.config.get("functions.source")) +
                " folder uploaded successfully");
        }
        catch (err) {
            utils_1.logWarning(clc.yellow("functions:") + " Upload Error: " + err.message);
            throw err;
        }
    }
}
exports.deploy = deploy;
