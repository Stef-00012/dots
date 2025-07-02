import { Gdk, Gtk } from "ags/gtk4";
import type { Accessor, Setter } from "ags";
import { execAsync } from "ags/process";
import Adw from "gi://Adw";
import { barHeight } from "@/bar/Bar";
import {
	SESSION_MENU_BUTTON_GAP,
	SESSION_MENU_BUTTON_HEIGHT,
	SESSION_MENU_BUTTON_WIDTH,
} from "@/constants/config";
import Pango from "gi://Pango?version=1.0";

interface Props {
	gdkmonitor: Gdk.Monitor;
	visible: Accessor<boolean>;
	setVisible: Setter<boolean>;
}

export default function SessionMenu({
	gdkmonitor,
	visible,
	setVisible,
}: Props) {
	function handleExternalClick() {
		setVisible(false);
	}

	function handleEscKey(
		_e: Gtk.EventControllerKey,
		keyval: number,
		_: number,
		_mod: number,
	) {
		if (keyval === Gdk.KEY_Escape) setVisible(false);
	}

	return (
		<Gtk.Window
			widthRequest={gdkmonitor.geometry.width}
			heightRequest={gdkmonitor.geometry.height}
			class="session-menu"
			title="AGS Session Menu"
			visible={visible}
			display={gdkmonitor.display}
			onCloseRequest={() => {
				setVisible(false);
			}}
		>
			<Gtk.EventControllerKey onKeyPressed={handleEscKey} />

			<Gtk.GestureClick
				button={Gdk.BUTTON_PRIMARY}
				onPressed={handleExternalClick}
				propagationPhase={Gtk.PropagationPhase.TARGET}
			/>

			<Adw.Clamp
				orientation={Gtk.Orientation.VERTICAL}
				maximumSize={
					SESSION_MENU_BUTTON_HEIGHT * 2 + SESSION_MENU_BUTTON_GAP
				}
				marginTop={barHeight}
			>
				<Adw.Clamp
					maximumSize={
						SESSION_MENU_BUTTON_WIDTH * 4 +
						SESSION_MENU_BUTTON_GAP * 3
					}
					hexpand
					vexpand
				>
					<box
						orientation={Gtk.Orientation.VERTICAL}
						spacing={SESSION_MENU_BUTTON_GAP}
					>
						<box spacing={SESSION_MENU_BUTTON_GAP}>
							<button
								widthRequest={SESSION_MENU_BUTTON_WIDTH}
								heightRequest={SESSION_MENU_BUTTON_HEIGHT}
								onClicked={() => {
									execAsync("loginctl lock-session");
									setVisible(false);
								}}
							>
								<box
									orientation={Gtk.Orientation.VERTICAL}
									valign={Gtk.Align.CENTER}
								>
									<image
										pixelSize={60}
										iconName="mi-lock-symbolic"
									/>

									<label
										wrapMode={Pango.WrapMode.WORD}
										justify={Gtk.Justification.CENTER}
										label="Lock"
									/>
								</box>
							</button>

							<button
								widthRequest={SESSION_MENU_BUTTON_WIDTH}
								heightRequest={SESSION_MENU_BUTTON_HEIGHT}
								onClicked={() => {
									execAsync("systemctl suspend");
									setVisible(false);
								}}
							>
								<box
									orientation={Gtk.Orientation.VERTICAL}
									valign={Gtk.Align.CENTER}
								>
									<image
										pixelSize={60}
										iconName="mi-dark-mode-symbolic"
									/>

									<label
										wrapMode={Pango.WrapMode.WORD}
										justify={Gtk.Justification.CENTER}
										label="Sleep"
									/>
								</box>
							</button>

							<button
								widthRequest={SESSION_MENU_BUTTON_WIDTH}
								heightRequest={SESSION_MENU_BUTTON_HEIGHT}
								onClicked={() => {
									execAsync("pkill Hyprland");
								}}
							>
								<box
									orientation={Gtk.Orientation.VERTICAL}
									valign={Gtk.Align.CENTER}
								>
									<image
										pixelSize={60}
										iconName="mi-logout-symbolic"
									/>

									<label
										wrapMode={Pango.WrapMode.WORD}
										justify={Gtk.Justification.CENTER}
										label="Logout"
									/>
								</box>
							</button>

							<button
								widthRequest={SESSION_MENU_BUTTON_WIDTH}
								heightRequest={SESSION_MENU_BUTTON_HEIGHT}
								onClicked={() => {
									execAsync("kitty btop");
								}}
							>
								<box
									orientation={Gtk.Orientation.VERTICAL}
									valign={Gtk.Align.CENTER}
								>
									<image
										pixelSize={60}
										iconName="mi-browse-activity-symbolic"
									/>

									<label
										wrapMode={Pango.WrapMode.WORD}
										justify={Gtk.Justification.CENTER}
										label="Task Manager"
									/>
								</box>
							</button>
						</box>

						<box spacing={SESSION_MENU_BUTTON_GAP}>
							<button
								widthRequest={SESSION_MENU_BUTTON_WIDTH}
								heightRequest={SESSION_MENU_BUTTON_HEIGHT}
								onClicked={() => {
									execAsync("systemctl hibernate");
								}}
							>
								<box
									orientation={Gtk.Orientation.VERTICAL}
									valign={Gtk.Align.CENTER}
								>
									<image
										pixelSize={60}
										iconName="mi-downloading-symbolic"
									/>

									<label
										wrapMode={Pango.WrapMode.WORD}
										justify={Gtk.Justification.CENTER}
										label="Hibernate"
									/>
								</box>
							</button>

							<button
								widthRequest={SESSION_MENU_BUTTON_WIDTH}
								heightRequest={SESSION_MENU_BUTTON_HEIGHT}
								onClicked={() => {
									execAsync("systemctl poweroff");
								}}
							>
								<box
									orientation={Gtk.Orientation.VERTICAL}
									valign={Gtk.Align.CENTER}
								>
									<image
										pixelSize={60}
										iconName="mi-power-settings-new-symbolic"
									/>

									<label
										wrapMode={Pango.WrapMode.WORD}
										justify={Gtk.Justification.CENTER}
										label="Shutdown"
									/>
								</box>
							</button>

							<button
								widthRequest={SESSION_MENU_BUTTON_WIDTH}
								heightRequest={SESSION_MENU_BUTTON_HEIGHT}
								onClicked={() => {
									execAsync("reboot");
								}}
							>
								<box
									orientation={Gtk.Orientation.VERTICAL}
									valign={Gtk.Align.CENTER}
								>
									<image
										pixelSize={60}
										iconName="mi-restart-alt-symbolic"
									/>

									<label
										wrapMode={Pango.WrapMode.WORD}
										justify={Gtk.Justification.CENTER}
										label="Reboot"
									/>
								</box>
							</button>

							<button
								widthRequest={SESSION_MENU_BUTTON_WIDTH}
								heightRequest={SESSION_MENU_BUTTON_HEIGHT}
								onClicked={() => {
									execAsync(
										"systemctl reboot --firmware-setup",
									);
								}}
							>
								<box
									orientation={Gtk.Orientation.VERTICAL}
									valign={Gtk.Align.CENTER}
								>
									<image
										pixelSize={60}
										iconName="mi-settings-applications-symbolic"
									/>

									<label
										wrap
										wrapMode={Pango.WrapMode.WORD}
										justify={Gtk.Justification.CENTER}
										label="UEFI"
									/>
								</box>
							</button>
						</box>
					</box>
				</Adw.Clamp>
			</Adw.Clamp>
		</Gtk.Window>
	);
}
