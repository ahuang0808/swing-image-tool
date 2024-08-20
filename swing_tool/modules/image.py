from importlib import resources

from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont


class SwingImageBuilderError(Exception):
    def __init__(self):
        super().__init__("Header width not equals to the footer width.")


class SwingImageBuilder:
    HEADER_PATH = resources.files(__package__).joinpath("../static/header.jpg")
    FOOTER_PATH = resources.files(__package__).joinpath("../static/footer.jpg")
    DESCRIPTION_FONT_PATH = resources.files(__package__).joinpath(
        "../static/SourceHanSansCN-Regular.otf",
    )
    FONT_SIZE = 150
    FONT_COLOR = (0, 0, 0)

    def build(self, image_path: str, description: str):
        """
        Build an image with swing header, footer, and description.

        Args:
        image_path (str): The image path of the raw image which should be 1:1
        description (str): Description in the image footer

        Return:
        PIL.Image: Combined image
        """
        header = Image.open(self.HEADER_PATH)
        footer = Image.open(self.FOOTER_PATH)
        font = ImageFont.truetype(self.DESCRIPTION_FONT_PATH, self.FONT_SIZE)
        image = Image.open(image_path)
        draw = ImageDraw.Draw(footer)

        # Draw description on the footer.
        if description:
            description_width, description_height = draw.textbbox(
                (0, 0),
                description,
                font=font,
            )[2:4]
            draw.text(
                xy=(
                    (footer.width - description_width) // 2,
                    (footer.height - description_height) // 2,
                ),
                text=description,
                font=font,
                fill=self.FONT_COLOR,
            )

        # Header and footer's width must be same.
        target_width = header.width
        if target_width != footer.width:
            raise SwingImageBuilderError

        # Crop the image to 1:1 centered
        width, height = image.size
        min_side = min(width, height)
        left = (width - min_side) // 2
        top = (height - min_side) // 2
        right = left + min_side
        bottom = top + min_side
        cropped_image = image.crop((left, top, right, bottom))
        resized_image = cropped_image.resize((target_width, target_width))

        # Create new image for combination.
        total_height = header.height + resized_image.height + footer.height
        new_image = Image.new("RGB", (target_width, total_height))

        # Paste all images to the new image.
        new_image.paste(header, (0, 0))
        new_image.paste(resized_image, (0, header.height))
        new_image.paste(footer, (0, header.height + resized_image.height))

        return new_image
