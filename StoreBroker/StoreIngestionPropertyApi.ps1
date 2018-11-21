# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Add-Type -TypeDefinition @"
   public enum StoreBrokerProductPropertyProperty
   {
       canCollectKinectData,
       canInstallOnRemovableMedia,
       category,
       hasLocalCooperative,
       hasLocalMultiplayer,
       hasThirdPartyAddOn,
       hasOnlineCooperative,
       hasOnlineMultiplayer,
       isAccessible,
       isAutomaticBackupAvailable,
       isBroadcastingEnabled,
       isCrossPlayEnabled,
       isGameDvrEnabled,
       localCooperativeMaxPlayers,
       localCooperativeMinPlayers,
       localMultiplayerMaxPlayers,
       localMultiplayerMinPlayers,
       privacyPolicyUri,
       resourceType,
       revisionToken,
       subcategories,
       supportContact,
       websiteUri
   }
"@

function Get-ProductProperty
{
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "", Justification="Methods called within here make use of PSShouldProcess, and the switch is passed on to them inherently.")]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({if ($_.Length -le 12) { throw "It looks like you supplied an AppId instead of a ProductId.  Use Get-Product with -AppId to find the ProductId for this AppId." } else { $true }})]
        [string] $ProductId,

        [string] $SubmissionId,

        [string] $PropertyId,

        [switch] $SinglePage,

        [string] $ClientRequestId,

        [string] $CorrelationId,

        [string] $AccessToken,

        [switch] $NoStatus
    )

    Write-InvocationLog

    try
    {
        $singleQuery = (-not [String]::IsNullOrWhiteSpace($PropertyId))
        $telemetryProperties = @{
            [StoreBrokerTelemetryProperty]::ProductId = $ProductId
            [StoreBrokerTelemetryProperty]::SubmissionId = $SubmissionId
            [StoreBrokerTelemetryProperty]::PropertyId = $PropertyId
            [StoreBrokerTelemetryProperty]::SingleQuery = $singleQuery
            [StoreBrokerTelemetryProperty]::ClientRequestId = $ClientRequesId
            [StoreBrokerTelemetryProperty]::CorrelationId = $CorrelationId
        }

        $getParams = @()
        if (-not [String]::IsNullOrWhiteSpace($SubmissionId))
        {
            $getParams += "submissionId=$SubmissionId"
        }

        $params = @{
            "ClientRequestId" = $ClientRequestId
            "CorrelationId" = $CorrelationId
            "AccessToken" = $AccessToken
            "TelemetryEventName" = "Get-ProductProperty"
            "TelemetryProperties" = $telemetryProperties
            "NoStatus" = $NoStatus
        }

        if ($singleQuery)
        {
            $params["UriFragment"] = "products/$ProductId/properties/$PropertyId`?" + ($getParams -join '&')
            $params["Method" ] = 'Get'
            $params["Description"] = "Getting property $PropertyId for $ProductId (SubmissionId: $SubmissionId)"

            return Invoke-SBRestMethod @params
        }
        else
        {
            $params["UriFragment"] = "products/$ProductId/properties`?" + ($getParams -join '&')
            $params["Description"] = "Getting properties for $ProductId (SubmissionId: $SubmissionId)"
            $params["SinglePage" ] = $SinglePage

            return Invoke-SBRestMethodMultipleResult @params
        }
    }
    catch
    {
        throw
    }
}

function New-ProductProperty
{
    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParametersetName="Object")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "", Justification="Methods called within here make use of PSShouldProcess, and the switch is passed on to them inherently.")]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({if ($_.Length -le 12) { throw "It looks like you supplied an AppId instead of a ProductId.  Use Get-Product with -AppId to find the ProductId for this AppId." } else { $true }})]
        [string] $ProductId,

        [string] $SubmissionId,

        [Parameter(
            Mandatory,
            ParameterSetName="Object")]
        [PSCustomObject] $Object,

        [Parameter(ParameterSetName="Individual")]
        [ValidateSet('ApplicationProperty', 'AddonProperty', 'BundleProperty', 'AvatarProperty', 'IoTProperty', 'AzureProperty')]
        [string] $Type,

        [string] $ClientRequestId,

        [string] $CorrelationId,

        [string] $AccessToken,

        [switch] $NoStatus
    )

    Write-InvocationLog

    try
    {
        $telemetryProperties = @{
            [StoreBrokerTelemetryProperty]::ProductId = $ProductId
            [StoreBrokerTelemetryProperty]::SubmissionId = $SubmissionId
            [StoreBrokerTelemetryProperty]::UsingObject = ($null -ne $Object)
            [StoreBrokerTelemetryProperty]::ResourceType = $Type
            [StoreBrokerTelemetryProperty]::ClientRequestId = $ClientRequesId
            [StoreBrokerTelemetryProperty]::CorrelationId = $CorrelationId
        }

        $getParams = @()
        if (-not [String]::IsNullOrWhiteSpace($SubmissionId))
        {
            $getParams += "submissionId=$SubmissionId"
        }

        $hashBody = $Object
        if ($null -eq $hashBody)
        {
            # Convert the input into a Json body.
            $hashBody = @{}

            # TODO: Not sure what I should really be doing here.
            if (-not [String]::IsNullOrWhiteSpace($Type))
            {
                $hashBody[[StoreBrokerProductPropertyProperty]::resourceType] = $Type
            }
        }

        $body = Get-JsonBody -InputObject $hashBody
        Write-Log -Message "Body: $body" -Level Verbose

        $params = @{
            "UriFragment" = "products/$ProductId/properties`?" + ($getParams -join '&')
            "Method" = 'Post'
            "Description" = "Creating new property for $ProductId (SubmissionId: $SubmissionId)"
            "Body" = $body
            "ClientRequestId" = $ClientRequestId
            "CorrelationId" = $CorrelationId
            "AccessToken" = $AccessToken
            "TelemetryEventName" = "New-ProductProperty"
            "TelemetryProperties" = $telemetryProperties
            "NoStatus" = $NoStatus
        }

        return Invoke-SBRestMethod @params
    }
    catch
    {
        throw
    }
}

function Set-ProductProperty
{
    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParametersetName="Object")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "", Justification="Methods called within here make use of PSShouldProcess, and the switch is passed on to them inherently.")]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({if ($_.Length -le 12) { throw "It looks like you supplied an AppId instead of a ProductId.  Use Get-Product with -AppId to find the ProductId for this AppId." } else { $true }})]
        [string] $ProductId,

        [Parameter(Mandatory)]
        [string] $SubmissionId,

        [Parameter(
            Mandatory,
            ParameterSetName="Individual")]
        [string] $PropertyId,

        [Parameter(
            Mandatory,
            ParameterSetName="Object")]
        [PSCustomObject] $Object,

        [Parameter(ParameterSetName="Individual")]
        [ValidateSet('ApplicationProperty', 'AddonProperty', 'BundleProperty', 'AvatarProperty', 'IoTProperty', 'AzureProperty')]
        [string] $Type,

        [Parameter(Mandatory)]
        [string] $RevisionToken,

        [string] $ClientRequestId,

        [string] $CorrelationId,

        [string] $AccessToken,

        [switch] $NoStatus
    )

    Write-InvocationLog

    try
    {
        if ($null -ne $Object)
        {
            $PropertyId = $Object.id
        }

        $telemetryProperties = @{
            [StoreBrokerTelemetryProperty]::ProductId = $ProductId
            [StoreBrokerTelemetryProperty]::SubmissionId = $SubmissionId
            [StoreBrokerTelemetryProperty]::PropertyId = $PropertyId
            [StoreBrokerTelemetryProperty]::UsingObject = ($null -ne $Object)
            [StoreBrokerTelemetryProperty]::ResourceType = $Type
            [StoreBrokerTelemetryProperty]::RevisionToken = $RevisionToken
            [StoreBrokerTelemetryProperty]::ClientRequestId = $ClientRequesId
            [StoreBrokerTelemetryProperty]::CorrelationId = $CorrelationId
        }

        $getParams = @()
        if (-not [String]::IsNullOrWhiteSpace($SubmissionId))
        {
            $getParams += "submissionId=$SubmissionId"
        }

        $hashBody = $Object
        if ($null -eq $hashBody)
        {
            # Convert the input into a Json body.
            $hashBody = @{}
            $hashBody[[StoreBrokerProductPropertyProperty]::revisionToken] = $RevisionToken

            if (-not [String]::IsNullOrWhiteSpace($Type))
            {
                # TODO: Not sure what I should really be doing here.
                $hashBody[[StoreBrokerProductPropertyProperty]::resourceType] = $Type
            }
        }

        $body = Get-JsonBody -InputObject $hashBody
        Write-Log -Message "Body: $body" -Level Verbose

        $params = @{
            "UriFragment" = "products/$ProductId/properties/$PropertyId`?" + ($getParams -join '&')
            "Method" = 'Put'
            "Description" = "Updating property $PropertyId for $ProductId (SubmissionId: $SubmissionId)"
            "Body" = $body
            "ClientRequestId" = $ClientRequestId
            "CorrelationId" = $CorrelationId
            "AccessToken" = $AccessToken
            "TelemetryEventName" = "Set-ProductProperty"
            "TelemetryProperties" = $telemetryProperties
            "NoStatus" = $NoStatus
        }

        return Invoke-SBRestMethod @params
    }
    catch
    {
        throw
    }
}

function Update-ProductProperty
{
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "", Justification="Methods called within here make use of PSShouldProcess, and the switch is passed on to them inherently.")]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({if ($_.Length -le 12) { throw "It looks like you supplied an AppId instead of a ProductId.  Use Get-Product with -AppId to find the ProductId for this AppId." } else { $true }})]
        [string] $ProductId,

        [Parameter(Mandatory)]
        [string] $SubmissionId,

        [PSCustomObject] $SubmissionData,

        [switch] $UpdateCategoryFromSubmissionData,

        [switch] $UpdatePropertiesFromSubmissionData,

        [switch] $UpdateContactInfoFromSubmissionData,

        [switch] $UpdateGamingOptions,

        [switch] $IsMinimalObject,

        [string] $ClientRequestId,

        [string] $CorrelationId,

        [string] $AccessToken,

        [switch] $NoStatus
    )

    Write-InvocationLog

    try
    {
        $providedSubmissionData = ($PSBoundParameters.ContainsKey('SubmissionData'))
        if ((-not $providedSubmissionData) -and $UpdateCategoryFromSubmissionData)
        {
            $message = 'Cannot request -UpdateCategoryFromSubmissionData without providing SubmissionData.'
            Write-Log -Message $message -Level Error
            throw $message
        }

        if ((-not $UpdateCategoryFromSubmissionData) -and (-not $UpdateContactInfoFromSubmissionData))
        {
            Write-Log -Message 'No modification parameters provided.  Nothing to do.' -Level Verbose
            return
        }

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        $params = @{
            'ProductId' = $ProductId
            'SubmissionId' = $SubmissionId
            'ClientRequestId' = $ClientRequestId
            'CorrelationId' = $CorrelationId
            'AccessToken' = $AccessToken
            'NoStatus' = $NoStatus
        }

        $property = Get-ProductProperty @params

        $setObjectPropertyParams = @{
            'InputObject' = $property
            'SkipIfNotDefined' = $IsMinimalObject
        }

        if ($UpdateCategoryFromSubmissionData)
        {
            if ((-not $IsMinimalObject) -or
                (Test-PropertyExists -InputObject $SubmissionData -Name 'applicationCategory'))
            {
                [System.Collections.ArrayList]$split = $SubmissionData.applicationCategory -split '_'
                $category = $split[0]
                $split.RemoveAt(0)
                $subCategory = $split
                if ($subCategory.Count -eq 0)
                {
                    $null = $subCategory.Add('NotSet')
                }

                Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::category) -Value $category
                Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::subcategories) -Value (ConvertTo-Json -InputObject $subCategory)
            }
        }

        <#
            TODO: The following exposed properties in the object model are not addressable yet via StoreBroker.
            See if $SubmissionData.hardwarePreferences might be able to map to some of these.

            /// <summary>
            /// List of TypeValuePairs of minimum system requirements. Values are dependant on type.
            /// Type: MemoryMinimum, Values: ["Not Specified", "300 MB", "750 MB", "1 GB", "2 GB", "4 GB", "6 GB", "8 GB", "12 GB", "16 GB", "20 GB"]
            /// Type: DirectXMinimum, Values: ["Not Specified", "Version 9", "Version 10", "Version 11", "DirectX 12 API, Hardware Feature Level 11", "DirectX 12 API, Hardware Feature Level 12"]
            /// Type: VideoMemoryMinimum, Values: ["Not Specified", "1 GB", "2 GB", "4 GB", "6 GB"]
            /// Type: ProcessorMinimum, Values: Open string
            /// Type: GraphicsMinimum, Values: Open string
            /// </summary>
            public IList<TypeValuePair> MinimumSystemRequirements { get; set; }

            /// <summary>
            /// List of TypeValuePairs of recommended system requirements. Values are dependant on type.
            /// Type: MemoryRecommended, Values: ["Not Specified", "300 MB", "750 MB", "1 GB", "2 GB", "4 GB", "6 GB", "8 GB", "12 GB", "16 GB", "20 GB"]
            /// Type: DirectXRecommended, Values: ["Not Specified", "Version 9", "Version 10", "Version 11", "DirectX 12 API, Hardware Feature Level 11", "DirectX 12 API, Hardware Feature Level 12"]
            /// Type: VideoMemoryRecommended, Values: ["Not Specified", "1 GB", "2 GB", "4 GB", "6 GB"]
            /// Type: ProcessorRecommended, Values: Open string
            /// Type: GraphicsRecommended, Values: Open string
            /// </summary>
            public IList<TypeValuePair> RecommendedSystemRequirements { get; set; }

            /// <summary>
            /// An array of TypeValuePairs that define the hardware preferences for your app.
            /// Type can be one of the following values: [Touch, Keyboard, Mouse, Camera, NfcHce, Nfc, BluetoothLE, Telephony].
            /// Value can be [Enabled, Disabled].
            /// </summary>
            public IList<TypeValuePair> MinimumHardwareRequirements { get; set; }

            /// <summary>
            /// An array of TypeValuePairs that define the Recommended hardware for your app.
            /// Type can be one of the following values: [Touch, Keyboard, Mouse, Camera, NfcHce, Nfc, BluetoothLE, Telephony].
            /// Value can be [Enabled, Disabled].
            /// </summary>
            public IList<TypeValuePair> RecommendedHardwareRequirements { get; set; }

            /// <summary>
            /// If Private Policy Uri is required
            /// </summary>
            public bool? IsPrivatePolicyRequired { get; set; }
        #>


        if ($UpdatePropertiesFromSubmissionData)
        {
            # TODO: No equivalent for: $SubmissionData.hardwarePreferences

            $setObjectPropertyParams['SourceObject'] = $SubmissionData
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::isGameDvrEnabled) -SourceName 'isGameDvrEnabled'
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::canInstallOnRemovableMedia) -SourceName 'canInstallOnRemovableMedia'
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::isAutomaticBackupAvailable) -SourceName 'automaticBackupEnabled'
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::isAccessible) -SourceName 'meetAccessibilityGuidelines'
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::hasThirdPartyAddOn) -SourceName 'hasExternalInAppProducts'
        }

        # TODO: Figure out a better way to identify which listing's information should be used
        # for the Contact Info (supportContact, privacyPolicyUri, websiteUri)
        if ($UpdateContactInfoFromSubmissionData)
        {
            $langCode = ($SubmissionData.listings |
                Get-Member -type NoteProperty |
                Select-Object -Property Name -First 1).Name

            if ([String]::IsNullOrWhiteSpace($langCode))
            {
                if (-not $IsMinimalObject)
                {
                    $message = "Provided SubmissionData does not have any Listing information. Contact info exists within the Listing information."
                    Write-Log -Message $message -Level Error
                    throw $message
                }
            }
            else
            {
                Write-Log -Message "Using the [$langCode] listing data for updating this product's support contact info." -Level Verbose
                $listing = $SubmissionData.listings.$langCode.baseListing

                $setObjectPropertyParams['SourceObject'] = $listing
                Set-ObjectProperty @setObjectPropertyParams -Name  ([StoreBrokerProductPropertyProperty]::supportContact) -SourceName 'supportContact'
                Set-ObjectProperty @setObjectPropertyParams -Name  ([StoreBrokerProductPropertyProperty]::privacyPolicyUri) -SourceName 'privacyPolicy'
                Set-ObjectProperty @setObjectPropertyParams -Name  ([StoreBrokerProductPropertyProperty]::websiteUri) -SourceName 'websiteUrl'
            }
        }

        if ($UpdateGamingOptions)
        {
            if ($null -eq $SubmissionData.gamingOptions)
            {
                $output = @()
                $output += "You selected to update the Gaming Options for this submission, but it appears you don't have"
                $output += "that section in your config file.  You should probably re-generate your config file with"
                $output += "New-StoreBrokerConfigFile, transfer any modified properties to that new config file, and then"
                $output += "re-generate your StoreBroker payload with New-SubmissionPackage."
                $output = $output -join [Environment]::NewLine
                Write-Log -Message $output -Level Error
                throw $output
            }

            #TODO: $SubmissionData.genres is no longer relevant. Is that ok?
            $setObjectPropertyParams['SourceObject'] = $SubmissionData.gamingOptions
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::hasLocalMultiplayer) -SourceName 'isLocalMultiplayer'
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::hasLocalCooperative) -SourceName 'isLocalCooperative'
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::hasOnlineMultiplayer) -SourceName 'isOnlineMultiplayer'
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::hasOnlineCooperative) -SourceName 'isOnlineCooperative'
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::localMultiplayerMinPlayers) -SourceName 'localMultiplayerMinPlayers'
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::localMultiplayerMaxPlayers) -SourceName 'localMultiplayerMaxPlayers'
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::localCooperativeMinPlayers) -SourceName 'localCooperativeMinPlayers'
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::localCooperativeMaxPlayers) -SourceName 'localCooperativeMaxPlayers'
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::isBroadcastingEnabled) -SourceName 'isBroadcastingPrivilegeGranted'
            Set-ObjectProperty @setObjectPropertyParams -Name ([StoreBrokerProductPropertyProperty]::isCrossPlayEnabled) -SourceName 'isCrossPlayEnabled'
            $canCollectKinectData = ($SubmissionData.gamingOptions.kinectDataForExternal -eq 'Enabled')
            if ((-not $IsMinimalObject) -or
                (Test-PropertyExists -InputObject $SubmissionData.gamingOptions -Name 'kinectDataForExternal'))
            {
                Set-ObjectProperty -InputObject $property -Name ([StoreBrokerProductPropertyProperty]::canCollectKinectData) -Value $canCollectKinectData
            }
        }

        $null = Set-ProductProperty @params -Object $property

        # Record the telemetry for this event.
        $stopwatch.Stop()
        $telemetryMetrics = @{ [StoreBrokerTelemetryMetric]::Duration = $stopwatch.Elapsed.TotalSeconds }
        $telemetryProperties = @{
            [StoreBrokerTelemetryProperty]::ProductId = $ProductId
            [StoreBrokerTelemetryProperty]::SubmissionId = $SubmissionId
            [StoreBrokerTelemetryProperty]::ProvidedSubmissionData = ($null -ne $SubmissionData)
            [StoreBrokerTelemetryProperty]::ClientRequestId = $ClientRequesId
            [StoreBrokerTelemetryProperty]::CorrelationId = $CorrelationId
        }

        Set-TelemetryEvent -EventName Update-ProductProperty -Properties $telemetryProperties -Metrics $telemetryMetrics
        return
    }
    catch
    {
        throw
    }
}
