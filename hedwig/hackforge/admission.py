import csv
import subprocess
from urllib.parse import quote


CSV_FILE = "Mars.csv"

GROUP_LINK = "https://chat.whatsapp.com/LpQ75vNacUdGmIPn5CWYx8"

MESSAGE = """Hi {name}!
You are invited to join the WhatsApp group for SCSE Media Team.
Join here:
{group_link}

Thank you!"""


def make_whatsapp_url(name, contact):
    message = MESSAGE.format(
        name=name,
        group_link=GROUP_LINK,
    )

    # Remove formatting characters from the phone number.
    phone = (
        contact
        .strip()
        .replace("+", "")
        .replace(" ", "")
        .replace("-", "")
    )

    return f"https://wa.me/{phone}?text={quote(message)}"


def load_participants():
    with open(CSV_FILE, newline="", encoding="utf-8") as file:
        return list(csv.DictReader(file))


def save_participants(participants):
    with open(CSV_FILE, "w", newline="", encoding="utf-8") as file:
        fieldnames = ["Name", "Contact", "Status"]

        writer = csv.DictWriter(
            file,
            fieldnames=fieldnames,
        )

        writer.writeheader()
        writer.writerows(participants)


def open_in_windows(url):
    """
    Open a URL using Windows from inside WSL.
    """
    subprocess.run(
        [
            "cmd.exe",
            "/c",
            "start",
            "",
            url,
        ],
        check=False,
    )


def main():
    participants = load_participants()

    # Add Status column if it doesn't already exist.
    for participant in participants:
        if not participant.get("Status"):
            participant["Status"] = "PENDING"

    # Save the initial Status column.
    save_participants(participants)

    total = len(participants)

    pending_count = sum(
        participant["Status"] == "PENDING"
        for participant in participants
    )

    sent_count = sum(
        participant["Status"] == "SENT"
        for participant in participants
    )

    skipped_count = sum(
        participant["Status"] == "SKIPPED"
        for participant in participants
    )

    print("=" * 60)
    print(" WhatsApp Group Invitation CLI")
    print("=" * 60)

    print(f"Total:   {total}")
    print(f"Pending: {pending_count}")
    print(f"Sent:    {sent_count}")
    print(f"Skipped: {skipped_count}")

    print("\nCommands:")
    print("  O = Open WhatsApp")
    print("  S = Skip participant")
    print("  Q = Quit")
    print()

    for participant in participants:

        # Skip people already processed.
        if participant["Status"] != "PENDING":
            continue

        name = participant["Name"].strip()
        contact = participant["Contact"].strip()

        print("=" * 60)
        print(f"Participant")
        print(f"Name:    {name}")
        print(f"Contact: {contact}")
        print(f"Status:  {participant['Status']}")
        print("=" * 60)

        while True:
            command = input("\n> ").strip().lower()

            # ---------------------------------------------------------
            # OPEN WHATSAPP
            # ---------------------------------------------------------

            if command == "o":
                url = make_whatsapp_url(name, contact)

                open_in_windows(url)

                print("\nWhatsApp has been opened.")
                print("Review the message and send it manually.")

                confirmation = input(
                    "\nPress ENTER after sending "
                    "or type 'n' to leave as PENDING: "
                ).strip().lower()

                if confirmation != "n":
                    participant["Status"] = "SENT"
                    save_participants(participants)

                    print("\n✓ Marked as SENT.")

                else:
                    print("\nLeft as PENDING.")

                break

            # ---------------------------------------------------------
            # SKIP
            # ---------------------------------------------------------

            elif command == "s":
                participant["Status"] = "SKIPPED"
                save_participants(participants)

                print("\n✓ Marked as SKIPPED.")

                break

            # ---------------------------------------------------------
            # QUIT
            # ---------------------------------------------------------

            elif command == "q":
                save_participants(participants)

                print("\nProgress saved.")
                print("Exiting...")

                return

            # ---------------------------------------------------------
            # INVALID COMMAND
            # ---------------------------------------------------------

            else:
                print(
                    "Invalid command. "
                    "Use O = open, S = skip, Q = quit."
                )

    print("\n" + "=" * 60)
    print("All pending participants have been processed.")
    print("=" * 60)


if __name__ == "__main__":
    main()
