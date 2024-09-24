#define REQUEST_FAIL_BAD_URL "!!URL!!"
#define REQUEST_FAIL_NOT_POSSIBLE "!!NP!!"

/**
 * Datum used to manage the functionality and cache for the cobalt.tools API.
 */
/datum/cobalt_tools
    /// The base API url to use.
    var/base_url = "https://api.cobalt.tools"

/**
 * Sends a request to the cobalt.tools API to fetch a tunnel for the audio file we want.
 */
/datum/cobalt_tools/proc/request_tunnel(normalized_url, request_type = "audio")
    var/static/headers = json_encode(list(
        "Accept" = "application/json",
        "Content-Type" = "application/json",
    ))

    var/body = json_encode(list(
        "url" = normalized_url,
        "downloadMode" = request_type,
    ))
    
    var/response_raw = rustg_http_request_blocking(RUSTG_HTTP_METHOD_POST, base_url, body, headers, null)
    var/list/response
    try
        response = json_decode(response_raw)
        if(!("body" in response))
            . = REQUEST_FAIL_BAD_URL
            CRASH("Failed to perform cobalt.tools API request: Response lacks body.")
        response = json_decode(response["body"])
    catch
        . = REQUEST_FAIL_BAD_URL
        CRASH("Failed to perform cobalt.tools API request: Failed to decode response.")

    var/static/list/valid_status = list("redirect", "tunnel")
    var/status = response["status"]
    if(!(status in valid_status))
        . = REQUEST_FAIL_NOT_POSSIBLE
        CRASH("Failed to perform cobalt.tools API request: [json_encode(response)]")
    return response["url"]
