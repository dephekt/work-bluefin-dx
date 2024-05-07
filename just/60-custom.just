# Setup scdaemon to disable ccid and use pcscd to play nice with gpg smartcards
alias scdaemon-gpgcard := setup-scdaemon-gpgcard

setup-scdaemon-gpgcard ACTION="":
    #!/usr/bin/env bash
    HOME="${HOME}"
    # Prompt the user for an action if not provided
    if [ -z "{{ACTION}}" ]; then
        read -p "Do you want to 'install' or 'uninstall' scdaemon configuration? (Type 'install' or 'uninstall'): " ACTION
    fi

    # Ensure valid input
    if [ "${ACTION}" != "install" ] && [ "${ACTION}" != "uninstall" ]; then
        echo "Invalid choice. Please specify 'install' or 'uninstall'."
        exit 1
    fi

    # Create the .gnupg directory if it doesn't exist
    mkdir -p "${HOME}/.gnupg"


    # Path to the scdaemon.conf file
    config_file="${HOME}/.gnupg/scdaemon.conf"
    
    touch "$config_file"

    # Lines to insert or remove
    lines_to_modify=(
        "disable-ccid"
        "pcsc-shared"
        "pcsc-driver /usr/lib64/libpcsclite.so.1"
    )

    # Initialize an empty array to keep track of missing lines
    lines_to_add=()

    # Perform the appropriate action based on ACTION
    if [ "${ACTION}" == "install" ]; then
        # Check each line and add if missing
        for line in "${lines_to_modify[@]}"; do
            grep -q "$line" "$config_file" || lines_to_add+=("$line")
        done

        # Append new lines if required
        if [ ${#lines_to_add[@]} -gt 0 ]; then
            printf "%s\n" "${lines_to_add[@]}" >> "$config_file"
            echo "Lines added to $config_file"
        else
            echo "Lines already present in $config_file"
        fi

    elif [ "${ACTION}" == "uninstall" ]; then
        # Loop through and remove lines if they exist
        for line in "${lines_to_modify[@]}"; do
            grep -Fq "$line" "$config_file" && sed -i "\|${line}|d" "$config_file"
        done

        echo "Lines removed from $config_file"
    fi
